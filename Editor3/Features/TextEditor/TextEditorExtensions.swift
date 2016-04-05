////
////  TextEditorExtensions.swift
////  Editor3
////
////  Created by Hoon H. on 2016/04/04.
////  Copyright © 2016 Eonil. All rights reserved.
////
//
//import Foundation
//import AppKit
//
//extension NSTextView {
//	func UTF16Selection() -> TextEditorUTF16Selection {
//	}
//	var UTF16Selection: TextEditorUTF16Selection {
//		get {
//			let pos = TextEditorUTF16Position(selectedRange().location)
//			let len = TextEditorUTF16Length(selectedRange().length)
//			return TextEditorUTF16Selection(position: pos, length: len)
//		}
//		set {
//			let pos = newValue.position.index
//			let len = newValue.length.length
////			let range = NSRange(
////			setSelectedRange(range)
//		}
//	}
//}