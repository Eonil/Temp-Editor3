//
//  CommonSignboardView.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class CommonSignboardView: NSView {
	var headText: String? {
		didSet {
			headTextField.objectValue = headText
		}
	}
	var bodyText: String? {
		didSet {
			bodyTextField.objectValue = bodyText
		}
	}
	private let headTextField = instantiateHeadTextField()
	private let bodyTextField = instantiateBodyTextField()
	private let contentBox = instantiateContentBox()
	private var customConstraints: [NSLayoutConstraint]?
	private var installer = ViewInstaller()
	deinit {
		installer.deinstallIfNeeded {
			NSLayoutConstraint.deactivateConstraints(customConstraints!)
		}
	}
}
private extension CommonSignboardView {
	private func render() {
		installer.installIfNeeded {
			addSubview(headTextField)
			addSubview(bodyTextField)
			addLayoutGuide(contentBox)

			customConstraints = [
				headTextField.topAnchor.constraintGreaterThanOrEqualToAnchor(topAnchor),
				bodyTextField.bottomAnchor.constraintLessThanOrEqualToAnchor(bottomAnchor),
				bodyTextField.topAnchor.constraintGreaterThanOrEqualToAnchor(headTextField.bottomAnchor, constant: 10),
				headTextField.centerXAnchor.constraintEqualToAnchor(contentBox.centerXAnchor),
				bodyTextField.centerXAnchor.constraintEqualToAnchor(contentBox.centerXAnchor),
				contentBox.topAnchor.constraintEqualToAnchor(headTextField.topAnchor),
				contentBox.bottomAnchor.constraintEqualToAnchor(bodyTextField.bottomAnchor),
				contentBox.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
				contentBox.centerYAnchor.constraintEqualToAnchor(centerYAnchor),
			]
			NSLayoutConstraint.activateConstraints(customConstraints!)
		}
		headTextField.preferredMaxLayoutWidth = bounds.width - 20
		bodyTextField.preferredMaxLayoutWidth = bounds.width - 20
	}
}
extension CommonSignboardView {
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		render()
	}
	override func resizeSubviewsWithOldSize(oldSize: NSSize) {
		super.resizeSubviewsWithOldSize(oldSize)
		render()
	}
}
private func instantiateContentBox() -> NSLayoutGuide {
	let	v	=	NSLayoutGuide()
	v.identifier	=	"CONTENT"
	return	v
}
private func instantiateBodyTextField() -> NSTextField {
	let	v	=	instantiateTextField()
	v.identifier	=	"BODY"
	v.font		=	NSFont.systemFontOfSize(12, weight: 0)
	v.textColor	=	NSColor.disabledControlTextColor()
	return	v
}
private func instantiateHeadTextField() -> NSTextField {
	let	v	=	instantiateTextField()
	v.identifier	=	"HEAD"
	v.font		=	NSFont.systemFontOfSize(14, weight: 0)
	v.textColor	=	NSColor.disabledControlTextColor()
	return	v
}
private func instantiateTextField() -> NSTextField {
	let	v	=	NSTextField()
	v.identifier	=	"BODY"
	v.translatesAutoresizingMaskIntoConstraints	=	false

	// You must set `editable` to `false` to make it to be resized by autolayout.
	v.editable		=	false
	v.bordered		=	false
	v.backgroundColor	=	nil
	v.alignment		=	.Center
	v.lineBreakMode		=	.ByWordWrapping
	return	v
}







