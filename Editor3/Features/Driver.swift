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

	////////////////////////////////////////////////////////////////

        static private(set) weak var theDriver: Driver?

	////////////////////////////////////////////////////////////////

        init() {
                mainMenuController = MainMenuController(editor: editor)
                editorUIController.editor = editor
                Driver.theDriver = self
        }
        deinit {
                Editor.Event.Notification.deregister(self)
                Driver.theDriver = nil
		editorUIController.editor = nil
        }

	////////////////////////////////////////////////////////////////

        let editor = Editor()
	let editorUIController = EditorUIController()
        let mainMenuController: MainMenuController
}













