//
//  FileNavigatorCellView.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class FileNavigatorCellView: NSTableCellView {
	weak var fileNode: FileNode?
	weak var textFieldDelegate: NSTextFieldDelegate? {
		get {
			return	nameTextField.delegate
		}
		set {
			nameTextField.delegate = newValue
		}
	}
	var state: (icon: NSImage, text: String)? {
		didSet {
			render()
		}
	}

	private let iconImageView = NSImageView()
	private let nameTextField = NavigatorCommonViewFactory.instantiateNodeTextField()
	private var installer = ViewInstaller()
}
// MARK: -
extension FileNavigatorCellView {
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		render()
	}
	override func resizeWithOldSuperviewSize(oldSize: NSSize) {
		super.resizeSubviewsWithOldSize(oldSize)
		render()
	}
	override var acceptsFirstResponder: Bool {
		get {
			return	true
		}
	}
	override func becomeFirstResponder() -> Bool {
		assert(window != nil)
		return	window?.makeFirstResponder(nameTextField) ?? false
	}
}
// MARK: -
private extension FileNavigatorCellView {
	func render() {
		installer.installIfNeeded {
			assert(self.imageView === nil)
			assert(self.textField === nil)
			self.imageView = iconImageView
			self.textField = nameTextField
			addSubview(iconImageView)
			addSubview(nameTextField)
		}
		iconImageView.image = state?.icon
		nameTextField.stringValue = state?.text ?? ""
	}
}











































