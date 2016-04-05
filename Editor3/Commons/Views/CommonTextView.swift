//
//  CommonTextView.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/05.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// A text view which provides:
/// - Proper background color for selected text when view is not the first responder.
class CommonTextView: NSTextView {
	/// Designated initialiser.
	init() {
		let inactiveSelectionBackgroundColor = EditorSelectedCodeBackgroundColor
			.colorWithAlphaComponent(0.4)
//			.blendedColorWithFraction(0.8, ofColor: NSColor.blackColor())
			.colorUsingColorSpace(NSColorSpace.deviceGrayColorSpace())
			?? NSColor.darkGrayColor()
		_customDrawingLayoutManager.colorMappings = [
			NSColor.secondarySelectedControlColor() : inactiveSelectionBackgroundColor,
		]
		_lockedContainer.designatedLayoutManager = _customDrawingLayoutManager
		_lockedContainer.replaceLayoutManager(_customDrawingLayoutManager)
		super.init(frame: CGRect.zero, textContainer: _lockedContainer)
	}
	@available(*,unavailable)
	override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
		preconditionAndReportFailureToDevelopers(container == _lockedContainer)
		super.init(frame: frameRect, textContainer: container)
	}
	@available(*,unavailable)
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	@available(*,unavailable)
	override func replaceTextContainer(newContainer: NSTextContainer) {
		preconditionAndReportFailureToDevelopers(newContainer.layoutManager === _customDrawingLayoutManager)
		super.replaceTextContainer(newContainer)
	}
	override var textContainer: NSTextContainer? {
		willSet {
			preconditionAndReportFailureToDevelopers(newValue?.layoutManager === _customDrawingLayoutManager)
		}
	}
	private let _lockedContainer = LockedContainer()
	private let _customDrawingLayoutManager = CustomDrawingLayoutManager()
}

private final class LockedContainer: NSTextContainer {
	weak var designatedLayoutManager: NSLayoutManager?
	override var layoutManager: NSLayoutManager? {
		willSet {
			preconditionAndReportFailureToDevelopers(designatedLayoutManager === newValue)
		}
	}
	private override func replaceLayoutManager(newLayoutManager: NSLayoutManager) {
		preconditionAndReportFailureToDevelopers(designatedLayoutManager === newLayoutManager)
		super.replaceLayoutManager(newLayoutManager)
	}
}

private final class CustomDrawingLayoutManager: NSLayoutManager {
	var colorMappings: [NSColor: NSColor] = [:]
	private override func fillBackgroundRectArray(rectArray: UnsafePointer<NSRect>, count rectCount: Int, forCharacterRange charRange: NSRange, color: NSColor) {
		func paintWithColor(fillColor: NSColor) {
			super.fillBackgroundRectArray(rectArray, count: rectCount, forCharacterRange: charRange, color: fillColor)
		}
		if let newColor = colorMappings[color] {
			newColor.setFill()
			paintWithColor(newColor)
			color.setFill()
		}
		else {
			paintWithColor(color)
		}
	}
}























