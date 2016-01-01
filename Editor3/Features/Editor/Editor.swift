//
//  Editor.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class Editor {
        enum Event {
                typealias Notification = EventNotification<Editor,Event>
                case DidChangeMainWorkspace
        }

        init() {
                NotificationUtility.register(self, [
                        NSWindowDidBecomeMainNotification,
                        NSWindowDidResignMainNotification,
                        ]) { [weak self] in self?.process($0) }
        }
        deinit {

        }

        // MARK: -
        /// A `Workspace` that is connected to main window.
        private(set) weak var mainWorkspace: Workspace? {
                didSet {
                        guard mainWorkspace !== oldValue else { return }
                        Event.Notification(sender: self, event: .DidChangeMainWorkspace).broadcast()
                }
        }
        private(set) var workspaces = ObjectSet<Workspace>()

        /// A workspace must be added only by a reaction for `NSDocument` init.
        /// Do not add arbitrary workspace.
        func addWorkspace(workspace: Workspace, forDocument: WorkspaceDocument) {
		workspaces.insert(workspace)
        }

        /// A workspace must be added only by a reaction for `NSDocument` deinit.
        /// Do not remove arbitrary workspace.
        /// If you want to remove a workspace programmatically, call 
        /// `Workspace.ADHOC_kill` instead of.
        func removeWorkspace(workspace: Workspace, forDocument: WorkspaceDocument) {
                if workspace === mainWorkspace {
                        mainWorkspace = nil
                }
                workspaces.remove(workspace)
        }
}
extension Editor {
        private func process(n: NSNotification) {
                func getWorkspaceForWindowOfNotification() -> Workspace? {
                        guard let window = n.object as? NSWindow else { return nil }
                        guard let document = NSDocumentController.sharedDocumentController().documentForWindow(window) else { return nil }
                        guard let workspaceDocument = document as? WorkspaceDocument else { return nil }
                        guard let workspace = workspaceDocument.workspace else { return nil }
                        return workspace
                }
//                debugLog(n)
                switch n.name {
                case NSWindowDidBecomeMainNotification:
                        let workspace = getWorkspaceForWindowOfNotification()
                        mainWorkspace = workspace
                case NSWindowDidResignMainNotification:
                        let workspace = getWorkspaceForWindowOfNotification()
                        if mainWorkspace === workspace {
                                mainWorkspace = nil
                        }
                default:
                        fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers("Received unexpected notification `\(n)`.")
                }
        }
}
















