//
//  PaneSplitView.swift
//  EditorUICommon
//
//  Created by Hoon H. on 2015/11/14.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit

public final class PaneSplitView: NSSplitView {

	// MARK: -
	public override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		super.wantsLayer = true
	}
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		super.wantsLayer = true
	}

	// MARK: -
	public var backgroundColor: NSColor? {
		didSet {
			guard let layer = layer else { return }
			layer.backgroundColor = backgroundColor?.CGColor
		}
	}
	public override var dividerColor: NSColor {
		get {
			return _dividerColor
		}
		set {
			_dividerColor = newValue
			needsLayout = true
			needsDisplay = true
		}
	}
	public override var dividerThickness: CGFloat {
		get {
			return _dividerThickness
		}
		set {
			_dividerThickness = newValue
			needsLayout = true
			needsDisplay = true
		}
	}

	@available(*,unavailable)
	public override var wantsLayer: Bool {
		willSet {
			assert(newValue == true, "You cannot set `false`.")
		}
	}
	public override func makeBackingLayer() -> CALayer {
		return CALayer()
	}

	// MARK: -
	private var _dividerColor: NSColor = NSColor.gridColor()
	private var _dividerThickness: CGFloat = 0
}




