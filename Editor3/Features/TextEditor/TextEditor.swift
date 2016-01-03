//
//  TextEditor.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class TextEditor: OwnerTextEditor {
        enum Error: ErrorType {
		case UnableToReadFromURL(NSURL, dueToError: NSError)
		case UnableToDecodeFileContentWithUTF8
                case UnableToEncodeContentStringWithUTF8
        }

        // MARK: -
        enum Event {
                typealias Notification = EventNotification<TextEditor,Event>
		case DidChangeEditingFileURL
                case DidChangeTextStorage
                case DidChageCodeCompletionRunningState
		case DidChangeIssues
        }

        weak var ownerWorkspace: OwnerWorkspace?
	var issues: [TextEditorIssue] = [] {
		didSet {
			Event.Notification(sender: self, event: .DidChangeIssues).broadcast()
		}
	}

        // MARK: -
        let codeCompletion = CodeCompletion()

	/// Sets new file URL.
	/// This always completes and throws nothing.
	/// Any error occured in setting process will be posted to
	/// `issues` property.
	var editingFileURL: NSURL? {
                get {
			return internalState.editingFileURL
                }
		set {
			issues.removeAll()
			do { try setEditingFileURLTransactionally(newValue) }
			catch let error { issues.append(TextEditorIssue.CannotSetEditingFileURLTo(newValue, dueToError: error)) }
		}
        }
        var storage: NSTextStorage? {
                get {
                        return internalState.storage
                }
	}
//	/// 0-based index.
//	var characterSelection: Range<Int>? {
//		didSet {
//		}
//	}
	private(set) var characterSelection: TextEditorCharacterSelection? {
		didSet {

		}
	}
        private(set) var codeCompletionRunningState: Bool = false {
                didSet {
//                        guard codeCompletionRunningState != oldValue else { return }
			Event.Notification(sender: self, event: .DidChageCodeCompletionRunningState).broadcast()
                }
        }

	private var internalState = InternalState()
}
extension TextEditor {
	func setCharacterSelectionWithUTF16Range(utf16Range: NSRange) {
		// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html
		assert(storage != nil)
		assert(utf16Range.toRange() != nil)
		characterSelection = nil
		guard utf16Range.location != NSNotFound else { return }
		guard utf16Range.length != NSNotFound else { return }
		guard let storage = storage else { return }
//		let maybeLineRange = (storage.string as NSString).lineRangeForRange(utf16Range)
//		assert(maybeLineRange.toRange() != nil)
//		guard let lineRange = maybeLineRange.toRange() else { return }
//		let startingLineIndex = lineRange.startIndex
		let string = storage.string as NSString
		var utf16Index = 0
		var lineCount = 0
		var selectionLineIndex = 0
		var selectionStartingBytes = 0
		while utf16Index < utf16Range.location {
			let lineRange = string.lineRangeForRange(NSMakeRange(utf16Index, 0))
			let lineEndUTF16Index = NSMaxRange(lineRange)
			if lineEndUTF16Index > utf16Range.location {
				// Found it.
				let prefixLocation = utf16Index
				let prefixLength = utf16Range.location - utf16Index
				let substringRange = NSRange(location: prefixLocation, length: prefixLength)
				let prefixString = string.substringWithRange(substringRange) as NSString
				let prefixByteLength = prefixString.dataUsingEncoding(NSUTF8StringEncoding)?.length ?? 0
				selectionLineIndex = lineCount
				selectionStartingBytes = prefixByteLength
			}
			utf16Index = lineEndUTF16Index
			lineCount += 1
		}
		let start = TextEditorCharacterSelectionPoint(line: selectionLineIndex, bytes: selectionStartingBytes)
		let end = start
		characterSelection = TextEditorCharacterSelection(range: (start, end))
	}
	func canComplete() -> Bool {
		return editingFileURL != nil
	}
        func showCompletion() throws {
//                // Test.
//                do {
//                        codeCompletion.candidates = [
//                                CodeCompletionCandidate(signature: "AAAA", comment: "BBBB"),
//                                CodeCompletionCandidate(signature: "AAAA", comment: "BBBB"),
//                                CodeCompletionCandidate(signature: "AAAA", comment: "BBBB"),
//                        ]
//                }
		assert(editingFileURL != nil)
		assert(characterSelection != nil)
		guard let editingFileURL = editingFileURL else { return }
		guard let characterSelection = characterSelection else { return }
		try saveStringToFile() // Required to activate Racer properly.
		let startPoint = characterSelection.range.start
		codeCompletion.reloadForFileURL(editingFileURL, point: startPoint)
                codeCompletionRunningState = true
        }
        func hideCompletion() {
		codeCompletionRunningState = false
        }
	func save() throws {
		try saveStringToFile()
	}
}
private extension TextEditor {
	/// Transaction is limited to cascaded operations that depends on external I/O.
	private func performTransaction(@noescape transaction: () throws ->()) throws {
		let backup = internalState
		do {
			try transaction()
		}
		catch let error {
			// Rollback.
			internalState = backup
			throw error
		}
	}
	/// Rollbacks on any error.
	private func setEditingFileURLTransactionally(url: NSURL?) throws {
		guard url != internalState.editingFileURL else { return }
		if let _ = editingFileURL, let _ = storage {
			try saveStringToFile()
		}
		try performTransaction {
			internalState.editingFileURL = nil
			internalState.storage = nil
			if let url = url {
				internalState.editingFileURL = url
				try reloadStringFromFile()
			}
		}
		Event.Notification(sender: self, event: .DidChangeEditingFileURL).broadcast()
		Event.Notification(sender: self, event: .DidChangeTextStorage).broadcast()
	}
	private func reloadStringFromFile() throws {
		assert(editingFileURL != nil)
		guard let editingFileURL = editingFileURL else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		try performTransaction {
			let data = try NSData(contentsOfURL: editingFileURL, options: [])
			guard let string = NSString(data: data, encoding: NSUTF8StringEncoding) else {
				throw Error.UnableToDecodeFileContentWithUTF8
			}
			let astring = NSAttributedString(string: string as String, attributes: [
				NSFontAttributeName:		CommonFont.codeFontOfSize(12),
				NSForegroundColorAttributeName:	EditorCodeForegroundColor,
				])
			let storage = NSTextStorage(attributedString: astring)
			internalState.storage = storage
			debugLog(storage)
		}
	}
	private func saveStringToFile() throws {
		assert(internalState.editingFileURL != nil)
		assert(internalState.storage != nil)
		guard let editingFileURL = internalState.editingFileURL else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		guard let storage = internalState.storage else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		guard let data = storage.string.dataUsingEncoding(NSUTF8StringEncoding) else { throw Error.UnableToEncodeContentStringWithUTF8 }
		try data.writeToURL(editingFileURL, options: [])
	}
}

private struct InternalState {
        var editingFileURL: NSURL?
        var storage: NSTextStorage?
}










