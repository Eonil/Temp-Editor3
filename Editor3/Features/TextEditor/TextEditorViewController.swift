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

        deinit {
		TextEditor.Event.Notification.deregisterAnyway(self)
        }

        weak var textEditor: TextEditor? {
                didSet {
                        render()
                }
        }

        override func viewDidLayout() {
                super.viewDidLayout()
                render()
        }

        // MARK: -
	private let issueSignboard = CommonSignboardView()
        private let scrollView = CommonViewFactory.instantiateScrollViewForCodeDisplayTextView()
        private let textView = CommonViewFactory.instantiateTextViewForCodeDisplay() as TextEditorTextView
        private let codeCompletionWindowController = CodeCompletionWindowController()
        private var installer = ViewInstaller()
}
extension TextEditorViewController {
        private func process(n: TextEditor.Event.Notification) {
                guard textEditor === n.sender else { return }
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
        private func render() {
                guard let textEditor = textEditor else { return }
                installer.installIfNeeded {
//			view.addSubview(issueSignboard)
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
                let newState = textEditor?.codeCompletionRunningState ?? false
                guard let window = view.window else { return }
                if newState {
                        let rectInView = CGRect(x: 100, y: 100, width: 100, height: 100)
                        let rectInWindow = view.convertRect(rectInView, toView: nil)
                        let rectInScreen = window.convertRectToScreen(rectInWindow)
                        codeCompletionWindowController.floatAroundRectInScreenSpace(rectInScreen)
                }
                else {
                        codeCompletionWindowController.sink()
                }
        }
}
extension TextEditorViewController: NSTextViewDelegate {
	func textViewDidChangeSelection(notification: NSNotification) {
		assert(textEditor != nil)
		guard let textEditor = textEditor else { return }
		let utf16Range = textView.selectedRange()
		textEditor.setCharacterSelectionWithUTF16Range(utf16Range)
	}
	func textView(textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
		assert(codeCompletionWindowController.codeCompletionViewController != nil)
		guard let textEditor = textEditor else { return false }

		debugLog(commandSelector)

		if commandSelector == Selector("complete:") {
			textEditor.hideCompletion()
			return true
		}
		if textEditor.codeCompletionRunningState {
			guard codeCompletingCommands.contains(commandSelector) else { return false }
			guard let codeCompletionViewController = codeCompletionWindowController.codeCompletionViewController else { return false }
			return codeCompletionViewController.tryToPerform(commandSelector, with: self)
		}
		return false
        }
}

private let codeCompletingCommands: [Selector] = [
        "moveUp:",
        "moveDown:",
        "moveLeft:",
        "moveRight:",
]













