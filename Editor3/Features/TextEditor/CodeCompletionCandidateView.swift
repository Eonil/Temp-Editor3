//
//  CodeCompletionCandidateView.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class CodeCompletionCandidateView: NSTableRowView {
        private let textField = NSTextField()
        private var installer = ViewInstaller()
        var candidate: CodeCompletionCandidate? {
                didSet {
                        render()
                }
        }
}
extension CodeCompletionCandidateView {
        private func render() {
                installer.installIfNeeded {
                        backgroundColor = NSColor.clearColor()
                        textField.bordered = false
                        textField.drawsBackground = false
			textField.font = CommonFont.codeFontWithSystemSize
                        addSubview(textField)
                }
                // Reload.
                do {
                        textField.stringValue = candidate?.signature ?? "????"
                }
                // Layout.
                do {
                        textField.frame = bounds
                }
                // Color.
                do {
			textField.textColor = selected
				? CommonColor.collectionItemTextSelected
				: CommonColor.collectionItemTextNormal
                }
        }
}
extension CodeCompletionCandidateView {
        override var selected: Bool {
                didSet {
                        render()
                }
        }
        override func viewDidMoveToWindow() {
                super.viewDidMoveToWindow()
                render()
        }
        override func resizeSubviewsWithOldSize(oldSize: NSSize) {
                super.resizeSubviewsWithOldSize(oldSize)
                render()
        }
        override func viewAtColumn(column: Int) -> AnyObject? {
                switch column {
                case 0:		return textField
                default:	fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers()
                }
        }
}















