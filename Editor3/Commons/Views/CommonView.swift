//
//  CommonView.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

class CommonView: NSView {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		super.wantsLayer	=	true
		layer!.backgroundColor	=	NSColor.clearColor().CGColor
//		layer!.backgroundColor	=	NSColor.magentaColor().CGColor
//		assert(layer! is _ClearColorOnlyLayer)
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		super.wantsLayer	=	true
		layer!.backgroundColor	=	NSColor.clearColor().CGColor
//		layer!.backgroundColor	=	NSColor.magentaColor().CGColor
//		assert(layer! is _ClearColorOnlyLayer)
	}

	func sizeThatFits(size: CGSize) -> CGSize {
		return size
	}
	func sizeToFit() {
		frame.size	=	sizeThatFits(frame.size)
	}
	
//	public override func makeBackingLayer() -> CALayer {
//		return	_ClearColorOnlyLayer()
//	}
	@available(*, unavailable)
	override var wantsLayer: Bool {
		get {
			return	super.wantsLayer
		}
		set {
			assert(newValue == true, "This class always use a layer, so you cannot set this property to `false`.")
			super.wantsLayer	=	newValue
		}
	}
	override var layer: CALayer? {
		get {
			return	super.layer
		}
		set {
			assert(newValue != nil, "This class always use a layer, so you cannot set this property to `nil`.")
//			assert(newValue is _ClearColorOnlyLayer)
			super.layer	=	newValue
		}
	}
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		if window != nil {
			needsLayout	=	true
		}
	}
	override func viewWillMoveToWindow(newWindow: NSWindow?) {
		if window != nil {
		}
		super.viewWillMoveToWindow(newWindow)
	}
	override func resizeSubviewsWithOldSize(oldSize: NSSize) {
		super.resizeSubviewsWithOldSize(oldSize)
	}

	override func didAddSubview(subview: NSView) {
		super.didAddSubview(subview)
	}
	override func willRemoveSubview(subview: NSView) {
		super.willRemoveSubview(subview)
	}
}


























