//
//  EditorUIController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/06.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

///
///
/// - Note:
///	Do not use `NSApplication.mainWindow` to retrieve current main window 
///	because querying the property can result wrong value in notification
///	handlers. Instead, track current main window manually by observing
///	related notificatios.
final class EditorUIController {
	init() {
		NotificationUtility.register(self, [
			NSWindowDidBecomeMainNotification,
			NSWindowDidResignMainNotification,
		]) { [weak self] in self?.process($0) }
		Editor.Event.Notification.register(self, self.dynamicType.process)
		Workspace.Event.Notification.register(self, self.dynamicType.process)
		WorkspaceDocument.Event.Notification.register(self, self.dynamicType.process)
	}
	deinit {
		WorkspaceDocument.Event.Notification.deregister(self)
		Workspace.Event.Notification.deregister(self)
		Editor.Event.Notification.deregister(self)
		NotificationUtility.deregister(self)
	}

	////////////////////////////////////////////////////////////////

	weak var editor: Editor? {
		didSet {
			render()
		}
	}

	////////////////////////////////////////////////////////////////

	private weak var trackedMainWindow: NSWindow? {
		didSet {
			scanMainWorkspace()
		}
	}

	////////////////////////////////////////////////////////////////

	private func process(n: NSNotification) {
		func getWindowFromNotification() -> NSWindow? {
			guard let window = n.object as? NSWindow else { return nil }
			return window
		}
		func getWorkspaceForWindowOfNotification() -> Workspace? {
			guard let window = getWindowFromNotification() else { return nil }
			guard let document = NSDocumentController.sharedDocumentController().documentForWindow(window) else { return nil }
			guard let workspaceDocument = document as? WorkspaceDocument else { return nil }
			guard let workspace = workspaceDocument.workspace else { return nil }
			return workspace
		}
		debugLog(n)
		switch n.name {
		case NSWindowDidBecomeMainNotification:
			debugLog(getWindowFromNotification())
			debugLog(getWindowFromNotification()?.getWorkspace())
			trackedMainWindow = getWindowFromNotification()

		case NSWindowDidResignMainNotification:
			assert(getWindowFromNotification() ==== trackedMainWindow)
			trackedMainWindow = nil

		default:
			fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers("Received unexpected notification `\(n)`.")
		}
	}
	private func process(n: WorkspaceDocument.Event.Notification) {
		switch n.event {
		case .DidRestore:
			let w = Workspace()
			let u = n.sender.fileURL?.URLByDeletingLastPathComponent
			w.locationURL = u		// Must set location BEFORE binding workspace to a document. Document rendering logic will scan URL from the workspace.
			n.sender.workspace = w		// Must bind workspace to the document first before adding it to editor.
			editor?.addWorkspace(w)
			scanMainWorkspace()
		}
	}
	private func process(n: Workspace.Event.Notification) {
		switch n.event {
		case .DidChangeLocation:
			scanMainWorkspace()

		case .DidChangeNavigationPaneSelection:
			break
		}
	}
        private func process(n: Editor.Event.Notification) {
                guard n.sender ==== editor else { return }
		switch n.event {
		case .DidChangeMainWorkspace:
			renderMainWorkspaceSelectionOnly()

		case .DidAddWorkspace(let workspace):
			renderWorkspaceDocumentsWithMutationEvents(.DidInsert(workspace))

		case .WillRemoveWorkspace(let workspace):
			renderWorkspaceDocumentsWithMutationEvents(.WillRemove(workspace))
		}
        }

	////////////////////////////////////////////////////////////////

	private func scanMainWorkspace() {
		editor?.mainWorkspace = trackedMainWindow?.getWorkspace()
	}

	////////////////////////////////////////////////////////////////

        private func render() {
		renderMainWorkspaceSelectionOnly()
		let oldWorkspaces = NSDocumentController.sharedDocumentController().findAllWorkspaces().toObjectSet()
		let newWorkspaces = editor?.workspaces ?? ObjectSet<Workspace>()
		let (insertions, removings) = newWorkspaces.differencesFrom(oldWorkspaces)
		for insertion in insertions {
			renderWorkspaceDocumentsWithMutationEvents(.DidInsert(insertion))
		}
		for removing in removings {
			renderWorkspaceDocumentsWithMutationEvents(.WillRemove(removing))
		}
        }
	private func renderMainWorkspaceSelectionOnly() {
		// Sync selection if needed.
		editor?.mainWorkspace?.findDocument()?.workspaceWindowController.window?.makeMainWindow()
	}
	private func renderWorkspaceDocumentsWithMutationEvents(event: ObjectSetMutationEvent<Workspace>) {
		switch event {
		case .DidInsert(let workspace):
			// Open workspace document if needed and possible.
			if workspace.findDocument() == nil {
				do {
					let newDocument = try NSDocumentController.sharedDocumentController().makeUntitledDocumentOfType("WorkspaceDocument")
					guard let newWorkspaceDocument = newDocument as? WorkspaceDocument else {
						reportToDevelopers("Cannot make a new `WorkspaceDocument`.")
						break
					}
					newWorkspaceDocument.workspace = workspace
					NSDocumentController.sharedDocumentController().addDocument(newWorkspaceDocument)
					newWorkspaceDocument.makeWindowControllers()
					newWorkspaceDocument.showWindows()
				}
				catch let error as NSError {
					NSApplication.sharedApplication().presentError(error)
				}
				scanMainWorkspace()

				// Test.
				workspace.locationURL = NSURL(string: "file:///Users/Eonil/Temp/a2")

//				if let locationURL = workspace.locationURL {
//					let u1 = locationURL.URLByAppendingPathComponent("Workspace.Editor3FileList")
//					NSDocumentController.sharedDocumentController()
//						.openDocumentWithContentsOfURL(u1, display: true, completionHandler: { [weak self] (newDocument: NSDocument?, _: Bool, error: NSError?) in
//							guard let newWorkspaceDocument = newDocument as? WorkspaceDocument else {
//								if let error = error {
//									reportToDevelopers(error)
//									NSApplication.sharedApplication().presentError(error)
//								}
//								return
//							}
//							newWorkspaceDocument.workspace = workspace
//							for _ in 0...0 {
//								guard let editor = self?.editor else { continue }
//								if newWorkspaceDocument.workspaceWindowController.window?.mainWindow == true {
//									editor.mainWorkspace = workspace
//								}
//							}
//					})
//				}
//				else {
//					NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(true)
//				}
			}

		case .WillRemove(let workspace):
			// Close workspace document if needed.
			if let document = workspace.findDocument() {
				document.workspace = nil
				document.close()
			}
		}
	}
}
extension EditorUIController: ADHOC_EditorUIComponentResolver {
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private extension NSWindow {
	func getWorkspace() -> Workspace? {
		return getWorkspaceForWindow(self)
	}
}
//private extension Workspace {
//	func getWindow() -> NSWindow? {
//		for document in NSDocumentController.sharedDocumentController().documents {
//			guard let workspaceDocument = document as? WorkspaceDocument else { continue }
//			guard workspaceDocument.workspace ==== self else { continue }
//			return workspaceDocument.workspaceWindowController.window
//		}
//		return nil
//	}
//}
private func getWorkspaceForWindow(window: NSWindow) -> Workspace? {
	for document in NSDocumentController.sharedDocumentController().documents {
		for windowController in document.windowControllers {
			guard windowController.window ==== window else { continue }
			guard let workspaceDocument = document as? WorkspaceDocument else { return nil }
			guard let workspace = workspaceDocument.workspace else { return nil }
			return workspace
		}
	}
	return nil
//	guard let document = NSDocumentController.sharedDocumentController().documentForWindow(window) else { return nil }
//	guard let workspaceDocument = document as? WorkspaceDocument else { return nil }
//	guard let workspace = workspaceDocument.workspace else { return nil }
//	return workspace
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private extension Workspace {
	func findDocument() -> WorkspaceDocument? {
		for document in NSDocumentController.sharedDocumentController().documents {
			guard let workspaceDocument = document as? WorkspaceDocument else { continue }
			guard workspaceDocument.workspace ==== self else { continue }
			return workspaceDocument
		}
		return nil
	}
}

private extension NSDocumentController {
	func findAllWorkspaces() -> [Workspace] {
		var workspaces = [Workspace]()
		for document in documents {
			guard let workspaceDocument = document as? WorkspaceDocument else { continue }
			guard let workspace = workspaceDocument.workspace else { continue }
			workspaces.append(workspace)
		}
		return workspaces
	}
}
private extension Array where Element: AnyObject {
	func toObjectSet() -> ObjectSet<Element> {
		var set = ObjectSet<Element>()
		for element in self {
			set.insert(element)
		}
		return set
	}
}













