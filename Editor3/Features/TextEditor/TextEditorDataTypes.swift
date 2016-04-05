//
//  TextEditorDataTypes.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct TextEditorUTF16Selection {
	var start: Int
	var end: Int

	func toRange() -> Range<Int> {
		return start..<end
	}
}

//struct TextEditorUTF16Position {
//	var index: Int
//	init(_ index: Int) {
//		self.index = index
//	}
//}
//struct TextEditorUTF16Length {
//	var length: Int
//	init(_ length: Int) {
//		self.length = length
//	}
//}
//struct TextEditorUTF16Selection {
//	var position: TextEditorUTF16Position
//	var length: TextEditorUTF16Length
//}
//
//func < (a: TextEditorUTF16Position, b: TextEditorUTF16Position) -> Bool {
//	return a.index < b.index
//}
//func <= (a: TextEditorUTF16Position, b: TextEditorUTF16Position) -> Bool {
//	return a.index <= b.index
//}
//func + (a: TextEditorUTF16Position, b: TextEditorUTF16Length) -> TextEditorUTF16Position {
//	return TextEditorUTF16Position(index: a.index + b.length)
//}
//func - (a: TextEditorUTF16Position, b: TextEditorUTF16Length) -> TextEditorUTF16Position {
//	return TextEditorUTF16Position(index: a.index - b.length)
//}
//func + (a: TextEditorUTF16Length, b: TextEditorUTF16Length) -> TextEditorUTF16Length {
//	return TextEditorUTF16Length(length: a.length + b.length)
//}
//func - (a: TextEditorUTF16Length, b: TextEditorUTF16Length) -> TextEditorUTF16Length {
//	return TextEditorUTF16Length(length: a.length - b.length)
//}
