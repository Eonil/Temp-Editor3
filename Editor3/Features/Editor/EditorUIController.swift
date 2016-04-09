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
	}
	deinit {
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
			editor?.mainWorkspace = trackedMainWindow?.getWorkspace()
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
			trackedMainWindow = getWindowFromNotification()

		case NSWindowDidResignMainNotification:
			assert(getWindowFromNotification() ==== trackedMainWindow)
			trackedMainWindow = nil

		default:
			fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers("Received unexpected notification `\(n)`.")
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
			if workspace.findDocument() == nil {
				// Open workspace document if needed and possible.
				guard let locationURL = workspace.locationURL else { break }
				let u1 = locationURL.URLByAppendingPathComponent("Workspace.Editor3FileList")
				NSDocumentController.sharedDocumentController()
					.openDocumentWithContentsOfURL(u1, display: true, completionHandler: { [weak self] (newDocument: NSDocument?, _: Bool, error: NSError?) in
						guard let newWorkspaceDocument = newDocument as? WorkspaceDocument else {
							if let error = error {
								reportToDevelopers(error)
								NSApplication.sharedApplication().presentError(error)
							}
							return
						}
						newWorkspaceDocument.workspace = workspace
						for _ in 0...0 {
							guard let editor = self?.editor else { continue }
							if newWorkspaceDocument.workspaceWindowController.window?.mainWindow == true {
								editor.mainWorkspace = workspace
							}
						}
				})
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
	guard let document = NSDocumentController.sharedDocumentController().documentForWindow(window) else { return nil }
	guard let workspaceDocument = document as? WorkspaceDocument else { return nil }
	guard let workspace = workspaceDocument.workspace else { return nil }
	return workspace
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private extension Workspace {
	func findDocument() -> WorkspaceDocument? {
		for document in NSDocumentController.sharedDocumentController().documents {
			guard let document = document as? WorkspaceDocument else { continue }
			return document
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













