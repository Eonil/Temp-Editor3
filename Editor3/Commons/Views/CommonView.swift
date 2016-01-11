//
//  CommonView.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Provides a common feature set for a view.
/// -	Always uses layer.
class CommonView: NSView {

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		super.wantsLayer = true
		assert(layer is TransparentLayer)
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		super.wantsLayer = true
		assert(layer is TransparentLayer)
	}
	deinit {
		assert(_isInstalled == false)
	}

	func installSubcomponents() {
		assert(_supercallCheckFlag == false)
		_supercallCheckFlag	=	true
	}
	func deinstallSubcomponents() {
		assert(_supercallCheckFlag == false)
		_supercallCheckFlag	=	true
	}
	func layoutSubcomponents() {
		assert(_supercallCheckFlag == false)
		_supercallCheckFlag	=	true
	}
	func sizeThatFits(size: CGSize) -> CGSize {
		return size
	}
	func sizeToFit() {
		frame.size	=	sizeThatFits(frame.size)
	}
	/// `setNeedsDisplayInRect(bounds)`.
	func setNeedsDisplay() {
		setNeedsDisplayInRect(bounds)
	}

	// MARK: -
	override func makeBackingLayer() -> CALayer {
		return TransparentLayer()
	}
	@available(*, unavailable)
	override var wantsLayer: Bool {
		get {
			return super.wantsLayer
		}
		set {
			assert(newValue == true, "This class always use a layer, so you cannot set this property to `false`.")
			super.wantsLayer = newValue
		}
	}
	override var layer: CALayer? {
		get {
			return super.layer
		}
		set {
			assert(newValue != nil, "This class always use a layer, so you cannot set this property to `nil`.")
			assert(newValue is TransparentLayer)
			super.layer = newValue
		}
	}

	@available(*,unavailable,message="Do not access this property youtself to avoid unwanted effect.")
	override var needsDisplay: Bool {
		didSet {
		}
	}
	override func setNeedsDisplayInRect(invalidRect: NSRect) {
		super.setNeedsDisplayInRect(invalidRect)
		guard let layer = layer else { return }
		layer.setNeedsDisplayInRect(invalidRect)
	}
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		if window != nil {
			_install()
			needsLayout	=	true
		}
	}
	override func viewWillMoveToWindow(newWindow: NSWindow?) {
		if window != nil {
			_deinstall()
		}
		super.viewWillMoveToWindow(newWindow)
	}
//	override func resizeSubviewsWithOldSize(oldSize: NSSize) {
//		super.resizeSubviewsWithOldSize(oldSize)
//		_layout()
//	}
	override func resizeWithOldSuperviewSize(oldSize: NSSize) {
		super.resizeWithOldSuperviewSize(oldSize)
		_layout()
	}

	override func didAddSubview(subview: NSView) {
		super.didAddSubview(subview)
	}
	override func willRemoveSubview(subview: NSView) {
		super.willRemoveSubview(subview)
	}

	// MARK: -
	private var _isInstalled = false
	private var _supercallCheckFlag = false
	private func _install() {
		assert(_isInstalled == false)

		assert(_supercallCheckFlag == false)
		installSubcomponents()
		assert(_supercallCheckFlag == true)
		_supercallCheckFlag	=	false

		_isInstalled		=	true

		_layout()
	}
	private func _deinstall() {
		assert(_isInstalled == true)

		assert(_supercallCheckFlag == false)
		deinstallSubcomponents()
		assert(_supercallCheckFlag == true)
		_supercallCheckFlag	=	false

		_isInstalled		=	false
	}
	private func _layout() {
		assert(_supercallCheckFlag == false)
		layoutSubcomponents()
		assert(_supercallCheckFlag == true)
		_supercallCheckFlag	=	false
	}
}

























































