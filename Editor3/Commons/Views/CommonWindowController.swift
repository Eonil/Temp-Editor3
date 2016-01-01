////
////  CommonWindowController.swift
////  Editor3
////
////  Created by Hoon H. on 2016/01/01.
////  Copyright © 2016 Eonil. All rights reserved.
////
//
//import Foundation
//import AppKit
//
///// Provides these stuffs:
///// - Autoresizing
/////
//class CommonWindowController: NSWindowController {
//
//        convenience init(contentViewController: NSViewController) {
//                let newWindow = NSWindow(contentViewController: contentViewController)
//                self.init(window: newWindow)
//        }
//        override init(window: NSWindow?) {
//                assert(window != nil)
//                preconditionAndReportFailureToDevelopers(window is NSWindow)
//                super.init(window: window)
//                installIfNeeded()
//                render()
//        }
//        deinit {
//                installer.deinstallIfNeeded {
//                        NotificationUtility.deregister(self)
//                }
//        }
//
//        @available(*,unavailable)
//        required init?(coder: NSCoder) {
//                fatalError("IB/SB are unsupported.")
//        }
//
//        // MARK: -
//        weak var workspace: Workspace? {
//                didSet {
//                        render()
//                }
//        }
//
//        // MARK: -
//        private weak var workspaceViewController: WorkspaceViewController?
//        private var installer = ViewInstaller()
//        private func installIfNeeded() {
//                installer.installIfNeeded {
//                        assert(window != nil)
//                        window?.setFrame(CGRect(x: 100, y: 100, width: 100, height: 100), display: true)
//                        NotificationUtility.register(self, [
//                                NSWindowDidResizeNotification,
//                                ], { [weak self] (n: NSNotification) -> () in
//                                        self?.process(n)
//                        })
//                }
//        }
//}
//extension CommonWindowController {
//        private func process(n: NSNotification) {
//                guard n.object === window else { return }
//                switch n.name {
//                case NSWindowDidResizeNotification:
//                        render()
//                default:
//                        reportToDevelopers("Received unexpected notification `\(n)`.")
//                }
//        }
//}
//extension CommonWindowController {
//        private func render() {
//                guard let workspace = workspace else { return }
//                guard let workspaceViewController = workspaceViewController else { return }
//                workspaceViewController.workspace = workspace
//        }
//}