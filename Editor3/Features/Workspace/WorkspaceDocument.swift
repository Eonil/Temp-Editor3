//
//  Document.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Cocoa

/// An adapter of workspace to OS support.
///
/// A document actually bound to a `.Editor3FileList` file in the workspace.
/// So `fileURL` points the file instead of the workspace directory itself.
/// (because there's no good way to support it without making the directory 
/// as a "bundle".)
/// 
/// Anyway `Workspace.locationURL` is URL to workspace directory itself,
/// so please don't be confused on this.
///
/// - Note:
///	A document object can be created by multiple reasons.
///	- Explicitly by a reaction of user input.
///	- Implicitly by OS due to "state restoration" feature.
///
///	When a new document object created by a user action, `EditorUIController` will
///	make it to be bound to an empty workspace which is not bound to any actual 
///	underlying directory.
///	Now you can,
///	- Set location of workspace by setting `Workspace.locationURL`.
///	- Replace `workspace` object.
///
///	If a new document object is created by OS "restoration", there's no way to detect
///	it except handling `DidRestore` event. `EditorUIController` handles the event
///	and bind a properly configured workspace to newrly restored document.
///
final class WorkspaceDocument: NSDocument {
	enum Error: ErrorType {
		case BadDocumentURL
	}
	enum Event {
		typealias Notification = EventNotification<WorkspaceDocument,Event>
		/// Notifies this document has been restored from last session by OS.
		/// In this case, the document has `fileURL`, but no proper workspace binding.
		/// Some object should handle this and bind a proper workspace object to
		/// this document.
		case DidRestore
	}

	////////////////////////////////////////////////////////////////

	override init() {
		super.init()
		Workspace.Event.Notification.register(self, self.dynamicType.process)
	}
	deinit {
		Workspace.Event.Notification.deregister(self)
		NotificationUtility.deregister(self)
	}

	////////////////////////////////////////////////////////////////

	weak var workspace: Workspace? {
		didSet {
			render()
		}
	}
	let workspaceWindowController = WorkspaceWindowController()

	////////////////////////////////////////////////////////////////

        override func makeWindowControllers() {
                debugLog("makeWindowControllers")
                super.makeWindowControllers()
                addWindowController(workspaceWindowController)
//                assert(workspace != nil)
//                workspaceWindowController.workspace = workspace
        }
        override class func autosavesInPlace() -> Bool {
                return true
        }
        override func dataOfType(typeName: String) throws -> NSData {
                // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
                // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
	override func readFromURL(url: NSURL, ofType typeName: String) throws {
		// Super method throws an exception. Do not call super method.
		guard let u = url.URLByDeletingLastPathComponent else {
			reportToDevelopers("Cannot get workspace root directory URL from URL `\(url)`.")
			throw Error.BadDocumentURL
		}

		workspace?.locationURL = u
	}
	override func restoreStateWithCoder(coder: NSCoder) {
		super.restoreStateWithCoder(coder)
		Event.Notification(sender: self, event: .DidRestore).broadcast()
	}

	////////////////////////////////////////////////////////////////

	private func process(n: NSNotification) {
		switch n.name {
		case NSWindowDidExposeNotification:
			guard let window = n.object as? NSWindow else { return }
			guard window ==== workspaceWindowController.window else { return }

			render()
		default:
			fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers("Received unexpected notification `\(n)`.")
		}
	}
	private func process(n: Workspace.Event.Notification) {
		guard n.sender ==== workspace else { return }
//		switch n.event {
//		case .DidChangeLocation:
//
//		case .DidChangeNavigationPaneSelection:
//			break
//		}
		render()
	}
	private func processDocumentDidMove(error: NSError?) {
		render()
	}

	////////////////////////////////////////////////////////////////

	private func render() {
		fileURL = workspace?.locationURL?.URLByAppendingPathComponent("Workspace.Editor3FileList")
		workspaceWindowController.workspace = workspace
//		if workspaceWindowController.window?.mainWindow == true {
//		}
	}
}
extension WorkspaceDocument {
	override func moveToURL(url: NSURL, completionHandler: ((NSError?) -> Void)?) {
		super.moveToURL(url) { [weak self] error in
			self?.processDocumentDidMove(error)
			completionHandler?(error)
		}
	}
}




private extension String {
	func toURL() -> NSURL? {
		return NSURL(string: self)
	}
}





