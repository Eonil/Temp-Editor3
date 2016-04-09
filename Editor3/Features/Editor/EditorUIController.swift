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
		render()
//		switch n.event {
//		case .DidChangeMainWorkspace:
//			render()
//		case .
//		}
	}
	private func render() {
		guard let editor = editor else { return }
		editor.mainWorkspace = trackedMainWindow?.getWorkspace()
		guard let workspace = editor.mainWorkspace else { return }
		guard let window = workspace.getWindow() else { return }
		window.makeMainWindow()
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
private extension Workspace {
	func getWindow() -> NSWindow? {
		for document in NSDocumentController.sharedDocumentController().documents {
			guard let workspaceDocument = document as? WorkspaceDocument else { continue }
			guard workspaceDocument.workspace ==== self else { continue }
			return workspaceDocument.workspaceWindowController.window
		}
		return nil
	}
}
private func getWorkspaceForWindow(window: NSWindow) -> Workspace? {
	guard let document = NSDocumentController.sharedDocumentController().documentForWindow(window) else { return nil }
	guard let workspaceDocument = document as? WorkspaceDocument else { return nil }
	guard let workspace = workspaceDocument.workspace else { return nil }
	return workspace
}












