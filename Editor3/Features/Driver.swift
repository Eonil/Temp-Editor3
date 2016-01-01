//
//  Driver.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class Driver {

        // MARK: -
        static private(set) weak var theDriver: Driver?

        // MARK: -
        init() {
                mainMenuController = MainMenuController(editor: editor)
                
                Driver.theDriver = self
                Editor.Event.Notification.register(self, self.dynamicType.process)
        }
        deinit {
                Editor.Event.Notification.deregister(self)
                Driver.theDriver = nil
        }

        // MARK: -
        let editor = Editor()
        let mainMenuController: MainMenuController
        func test1() {
//                // Test.
//                let doc = WorkspaceDocument()
//                NSDocumentController.sharedDocumentController().addDocument(doc)
//                doc.makeWindowControllers()
//                doc.showWindows()
        }

        // MARK: -
        private func process(n: Editor.Event.Notification) {
                guard n.sender === editor else { return }
                renderWorkspacesForEvent(n.event)
        }

        private func renderWorkspacesForEvent(event: Editor.Event) {
                switch event {
                case .DidChangeMainWorkspace:
                        guard let mainWorkspace = editor.mainWorkspace else { return }
                        assert(mainWorkspace.ownerDocument != nil)
                        guard let workspaceDocument = mainWorkspace.ownerDocument else { return }
                        workspaceDocument.workspaceWindowController.window?.makeMainWindow()
                }
        }
}
















