//
//  WorkspaceWindowController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class WorkspaceWindowController: NSWindowController {

        convenience init() {
                let newWorkspaceViewController = WorkspaceViewController()
                let newWindow = WorkspaceWindow(contentViewController: newWorkspaceViewController)
                self.init(window: newWindow)
                workspaceViewController = newWorkspaceViewController
        }
        override init(window: NSWindow?) {
                assert(window != nil)
                preconditionAndReportFailureToDevelopers(window is WorkspaceWindow)
                super.init(window: window)
                installIfNeeded()
                render()
        }
        deinit {
                installer.deinstallIfNeeded {
                        NotificationUtility.deregister(self)
                }
        }

        @available(*,unavailable)
        required init?(coder: NSCoder) {
                fatalError("IB/SB are unsupported.")
        }

        // MARK: -
        weak var workspace: Workspace? {
                didSet {
                        render()
                }
        }

        // MARK: -
        private weak var workspaceViewController: WorkspaceViewController?
        private var installer = ViewInstaller()
        private func installIfNeeded() {
                installer.installIfNeeded {
                        assert(window != nil)
                        window?.setFrame(CGRect(x: 100, y: 100, width: 100, height: 100), display: true)
                        NotificationUtility.register(self, [
                                NSWindowDidResizeNotification,
                                ], { [weak self] (n: NSNotification) -> () in
                                        self?.process(n)
                        })
                }
        }
}
extension WorkspaceWindowController {
        private func process(n: NSNotification) {
                guard n.object === window else { return }
                switch n.name {
                case NSWindowDidResizeNotification:
                        render()
                default:
                        reportToDevelopers("Received unexpected notification `\(n)`.")
                }
        }
        private func process(n: Workspace.Event.Notification) {
                guard n.sender === self else { return }
                switch n.event {
                case .DidChangeLocation:
                        MARK_unimplemented()
		case .DidChangeNavigationPaneSelection:
			break
//                case .RecoverableError(let error):
//                        preconditionAndReportFailureToDevelopers(window != nil)
//                        guard let window = window else { return }
//                        window.presentError(error as NSError)
                }
        }
}
extension WorkspaceWindowController {
        private func render() {
//              guard let window = window else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                guard let workspace = workspace else { return }
                guard let workspaceViewController = workspaceViewController else { return }
                workspaceViewController.workspace = workspace
        }
}

private final class WorkspaceWindow: NSWindow {
        override var canBecomeMainWindow: Bool {
                get {
                        return true
                }
        }
}






















