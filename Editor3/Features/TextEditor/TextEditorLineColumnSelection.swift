//
//  TextEditorLineColumnSelection.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct TextEditorCharacterSelection {
	var range: (start: TextEditorCharacterSelectionPoint, end: TextEditorCharacterSelectionPoint)
}
struct TextEditorCharacterSelectionPoint {
	var line: Int
	var bytes: Int // Measured in Byte count of encoded UTF-8 string.
}