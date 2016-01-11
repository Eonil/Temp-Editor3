//
//  IssueNavigatorCellView.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/07.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class IssueNavigatorCellView: NSTableCellView {
	var issue: Issue? {
		didSet {
			render()
		}
	}

	// MARK: -
	private let iconImageView = NSImageView()
	private let nameTextField = NavigatorCommonViewFactory.instantiateNodeTextField()
	private var installer = ViewInstaller()
}
// MARK: -
extension IssueNavigatorCellView {
	@available(*,unavailable)
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		render()
	}
	@available(*,unavailable)
	override func resizeWithOldSuperviewSize(oldSize: NSSize) {
		super.resizeSubviewsWithOldSize(oldSize)
		render()
	}
	@available(*,unavailable)
	override var acceptsFirstResponder: Bool {
		get {
			return	true
		}
	}
	@available(*,unavailable)
	override func becomeFirstResponder() -> Bool {
		assert(window != nil)
		return	window?.makeFirstResponder(nameTextField) ?? false
	}
}
// MARK: -
extension IssueNavigatorCellView {
	private func render() {
		installer.installIfNeeded {
			assert(self.imageView === nil)
			assert(self.textField === nil)
			nameTextField.cell?.usesSingleLineMode = true
			nameTextField.editable = false
			nameTextField.bordered = false
			nameTextField.bezeled = false
			self.imageView = iconImageView
			self.textField = nameTextField
			addSubview(iconImageView)
			addSubview(nameTextField)
		}
		iconImageView.image = nil
		let _ = issue?.severity
		nameTextField.stringValue = issue?.message ?? ""
		MARK_adHoc()
	}
}









































