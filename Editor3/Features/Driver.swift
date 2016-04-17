//
//  Driver.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// The root manager of whole program.
final class Driver {

        init() {
                mainMenuController.editor = editor
                editorUIController.editor = editor
                mainMenuController.ADHOC_editorUIComponentResolver = editorUIController
        }
        deinit {
		editorUIController.editor = nil
        }

	////////////////////////////////////////////////////////////////

        let editor = Editor()
	let editorUIController = EditorUIController()
        let mainMenuController = MainMenuController()
}














