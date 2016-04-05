//
//  CodeCompletionViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class CodeCompletionViewController: CommonViewController {

	override init() {
		super.init()
		CodeCompletion.Event.Notification.register(self, self.dynamicType.process)
	}
	deinit {
		CodeCompletion.Event.Notification.deregister(self)
	}

        weak var codeCompletion: CodeCompletion? {
                didSet {
                        installIfNeeded()
                        render()
                }
        }

	// MARK: -
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		installIfNeeded()
		render()
	}
        override func moveUp(sender: AnyObject?) {
                // Do not call `super` because it does not have actual implementation.
                let selidx = tableView.selectedRow
                if selidx >= Int.min.successor() && selidx >= (0 + 1) {
                        let idx = tableView.selectedRow - 1
                        let idxs = NSIndexSet(index: idx)
                        tableView.selectRowIndexes(idxs, byExtendingSelection: false)
                }
        }
        override func moveDown(sender: AnyObject?) {
                // Do not call `super` because it does not have actual implementation.
                let selidx = tableView.selectedRow
                if selidx <= Int.max.predecessor() {
			let idx = tableView.selectedRow + 1
                        let idxs = NSIndexSet(index: idx)
                        tableView.selectRowIndexes(idxs, byExtendingSelection: false)
                }
        }

        // MARK: -
        private let scrollView = NSScrollView()
        private let tableView = NSTableView()
        private var installer = ViewInstaller()
        private func installIfNeeded() {
                installer.installIfNeeded {
                        scrollView.hasHorizontalScroller		=	true
                        scrollView.hasVerticalScroller			=	true
                        scrollView.drawsBackground			=	false

                        let expressionsColumn = NSTableColumn()
                        tableView.rowSizeStyle	=	NSTableViewRowSizeStyle.Small		//<	This is REQUIRED. Otherwise, cell icon/text layout won't work.
                        tableView.addTableColumn(expressionsColumn)
                        tableView.headerView				=	nil
                        tableView.backgroundColor			=	NSColor.clearColor()
                        tableView.selectionHighlightStyle		=	.Regular
                        tableView.draggingDestinationFeedbackStyle	=	.Regular
                        tableView.allowsEmptySelection			=	true
                        tableView.allowsMultipleSelection		=	false
                        tableView.focusRingType				=	.None
                        tableView.setDataSource(self)
                        tableView.setDelegate(self)

                        view.addSubview(scrollView)
                        scrollView.documentView = tableView
                }
        }
}
// MARK: -
extension CodeCompletionViewController {
        private func process(n: CodeCompletion.Event.Notification) {
                guard n.sender ==== codeCompletion else { return }
                render()
        }
}
// MARK: -
extension CodeCompletionViewController {
        private func render() {
                scrollView.frame = view.bounds
		tableView.reloadData()
                guard let window = view.window else { return }
                window.makeFirstResponder(tableView)
        }
}
// MARK: -
extension CodeCompletionViewController: NSTableViewDataSource {
	@objc
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return codeCompletion?.filteredCandidates.count ?? 0
	}
}
extension CodeCompletionViewController: NSTableViewDelegate {
	@objc
	func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		let VIEW_ID = NSStringFromClass(CodeCompletionCandidateView)
		let candidateView: CodeCompletionCandidateView = {
			if let candidateView = tableView.makeViewWithIdentifier(VIEW_ID, owner: nil) as? CodeCompletionCandidateView {
				return candidateView
			}
			return CodeCompletionCandidateView()
		}()
		candidateView.identifier = VIEW_ID
		candidateView.candidate = codeCompletion?.filteredCandidates[row]
		return candidateView
	}
	@objc
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let rowView = tableView.rowViewAtRow(row, makeIfNecessary: true)
		return rowView?.viewAtColumn(0) as? NSView
	}
	@objc
	func tableViewSelectionDidChange(notification: NSNotification) {
		func getIndex() -> Int? {
			let idx = tableView.selectedRow
			guard idx != NSNotFound else { return nil }
			assert(idx >= 0)
			assert(idx < tableView.numberOfRows)
			guard idx >= 0 else { return nil }
			guard idx < tableView.numberOfRows else { return nil }
			return idx
		}
		codeCompletion?.selectedCandidateIndex = getIndex()
	}
}











