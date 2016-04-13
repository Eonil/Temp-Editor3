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
	var characterSelectionInUTF16Range: NSRange? {
		didSet {
			debugLog(characterSelectionInUTF16Range)
		}
	}
        private(set) var isCodeCompletionRunning: Bool = false {
                didSet {
                        guard isCodeCompletionRunning != oldValue else { return }
			Event.Notification(sender: self, event: .DidChageCodeCompletionRunningState).broadcast()
                }
        }

	private var internalState = InternalState()
}
extension TextEditor {
	private func getCharacterSelectionWithUTF16Range(utf16Range: NSRange) -> TextEditorCharacterSelection? {
		// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html
		assert(storage != nil)
		assert(utf16Range.toRange() != nil)
		guard utf16Range.location != NSNotFound else { return nil }
		guard utf16Range.length != NSNotFound else { return nil }
		guard let storage = storage else { return nil }
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
		return TextEditorCharacterSelection(range: (start, end))
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
		guard let editingFileURL = editingFileURL else { return }
		guard let characterSelectionInUTF16Range = characterSelectionInUTF16Range else { return }
		guard let characterSelection = getCharacterSelectionWithUTF16Range(characterSelectionInUTF16Range) else { return }
		try saveStringToFile() // Required to activate Racer properly.
		let startPoint = characterSelection.range.start
		codeCompletion.reloadForFileURL(editingFileURL, point: startPoint)
                isCodeCompletionRunning = true
        }
        func hideCompletion() {
		isCodeCompletionRunning = false
		codeCompletion.removeAllCandidates()
        }
	func pasteCurrentCodeCompletionCandidate() {
		guard codeCompletion.filteredCandidates.count > 0 else { return }
		guard let candidateIndex = codeCompletion.selectedCandidateIndex else { return }
		let candidate = codeCompletion.filteredCandidates[candidateIndex].signature
		let signature = candidate.componentsSeparatedByString(" ").first ?? ""
		let insertionPoint = characterSelectionInUTF16Range?.location ?? 0
		let insertion = signature.attributed().styledAsCode()
		storage?.insertAttributedString(insertion, atIndex: insertionPoint)
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
			debugLog(string.attributed().styledAsCode())
			let storage = NSTextStorage(attributedString: string.attributed().styledAsCode())
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

private extension NSAttributedString {
	func styledAsCode() -> NSAttributedString {
		return fonted(CommonFont.codeFontOfSize(12)).colored(EditorCodeForegroundColor)
	}
}








