//
//  TextEditorViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class TextEditorViewController: CommonViewController {

	override init() {
		super.init()
		TextEditor.Event.Notification.register(self, self.dynamicType.process)
		CodeCompletion.Event.Notification.register(self, self.dynamicType.process)
	}
	deinit {
		CodeCompletion.Event.Notification.deregister(self)
		TextEditor.Event.Notification.deregister(self)
        }

        weak var textEditor: TextEditor? {
                didSet {
                        render()
                }
        }
	
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		render()
	}

        // MARK: -
	private let issueSignboard = CommonSignboardView()
        private let scrollView = CommonViewFactory.instantiateScrollViewForCodeDisplayTextView()
        private let textView = CommonViewFactory.instantiateTextViewForCodeDisplay() as TextEditorTextView
        private let codeCompletionWindowController = CodeCompletionWindowController()
        private var installer = ViewInstaller()
	private var autocompletionStartingPosition: Int?
}
extension TextEditorViewController {
        private func process(n: TextEditor.Event.Notification) {
                guard n.sender ==== textEditor else { return }
                switch n.event {
                case .DidChangeTextStorage:
                        render()
                case .DidChangeEditingFileURL:
                        render()
                case .DidChageCodeCompletionRunningState:
                        renderCodeCompletion()
		case .DidChangeIssues:
			render()
                }
        }
	private func process(n: CodeCompletion.Event.Notification) {
		guard n.sender ==== textEditor?.codeCompletion else { return }
		switch n.event {
		case .DidChangeSelectionIndex:
			renderCodeCompletion()
		case .DidChangeAllCandidates:
			break
		case .DidChangeFilteredCandidates:
			break
		}
	}
        private func render() {
                guard let textEditor = textEditor else { return }
                installer.installIfNeeded {
			view.addSubview(issueSignboard)
                        view.addSubview(scrollView)
                        scrollView.documentView = textView
                        textView.delegate = self
                        TextEditor.Event.Notification.reregisterAnyway(self, self.dynamicType.process)
                }

		issueSignboard.frame = view.bounds
		issueSignboard.hidden = textEditor.issues.count == 0
		issueSignboard.headText = "\(textEditor.issues)"
		scrollView.frame = view.bounds
		scrollView.hidden = textEditor.storage == nil || textEditor.issues.count > 0
                codeCompletionWindowController.codeCompletion = textEditor.codeCompletion
                if textView.layoutManager?.textStorage !== textEditor.storage {
                        textView.layoutManager?.replaceTextStorage(textEditor.storage ?? NSTextStorage())
			textView.editable = textEditor.storage != nil
                }
        }
        private func renderCodeCompletion() {
		let shouldBeRunning = textEditor?.isCodeCompletionRunning ?? false
		let isRunning = codeCompletionWindowController.isFloating
		if shouldBeRunning != isRunning {
			if shouldBeRunning {
				autocompletionStartingPosition = textView.selectedRange().location
				let selectionRectInScreen = textView.firstRectForCharacterRange(textView.selectedRange(), actualRange: nil)
				codeCompletionWindowController.floatAroundRectInScreenSpace(selectionRectInScreen)
			}
			else {
				codeCompletionWindowController.sink()
			}
		}

        }
}
extension TextEditorViewController {
	private func getCodeCompletionSearchExpression() -> String? {
		guard let autocompletionStartingPosition = autocompletionStartingPosition else { return nil }
		guard let currentSelectionEndPosition = textView.selectedRange().toRange()?.endIndex else { return nil }
		guard autocompletionStartingPosition <= currentSelectionEndPosition else { return nil }
		let capturingRange = autocompletionStartingPosition..<currentSelectionEndPosition
		guard let capturedString = textView.textStorage?.mutableString.substringWithRange(NSRange(capturingRange)) else { return nil }
		return capturedString
	}
}
extension TextEditorViewController: NSTextViewDelegate {
	@objc
	func textDidChange(notification: NSNotification) {
		textEditor?.codeCompletion.searchExpression = getCodeCompletionSearchExpression() ?? ""
	}
	@objc
	func textViewDidChangeSelection(notification: NSNotification) {
		assert(textEditor != nil)
		guard let textEditor = textEditor else { return }
		let utf16Range = textView.selectedRange()
		textEditor.setCharacterSelectionWithUTF16Range(utf16Range)
		if textView.selectedRange().location < autocompletionStartingPosition {
			textEditor.hideCompletion()
		}
//		if let autocompletionStartingPosition = autocompletionStartingPosition {
//			let range = NSRange(location: autocompletionStartingPosition, length: <#T##Int#>)
//			textView.textStorage?
//				.attributedSubstringFromRange(<#T##range: NSRange##NSRange#>)
//		}
	}
	@objc
	func textView(textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
		assert(codeCompletionWindowController.codeCompletionViewController != nil)
		guard let textEditor = textEditor else { return false }

		debugLog(commandSelector)

		switch commandSelector {
		case #selector(NSResponder.insertNewline(_:)):
			break
		default:
			break
		}
		if commandSelector == #selector(NSTextView.complete(_:)) {
			textEditor.hideCompletion()
			return true
		}
		if textEditor.isCodeCompletionRunning {
			guard codeCompletingCommands.contains(commandSelector) else { return false }
			guard let codeCompletionViewController = codeCompletionWindowController.codeCompletionViewController else { return false }
			return codeCompletionViewController.tryToPerform(commandSelector, with: self)
		}
		return false
        }
}

private let codeCompletingCommands: [Selector] = [
        #selector(NSResponder.moveUp(_:)),
        #selector(NSResponder.moveDown(_:)),
        #selector(NSResponder.moveLeft(_:)),
        #selector(NSResponder.moveRight(_:)),
]










