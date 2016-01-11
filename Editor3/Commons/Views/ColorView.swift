//
//  ColorView.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// A view that fills its background with an `NSColor`.
/// This is required because `CommonView` prohibited resetting 
/// `backgroudColor` of its layer.
final class ColorView: CommonView {

	// MARK: -
	var backgroundColor: NSColor? {
		didSet {
			guard backgroundColor != oldValue else { return }
			render(false)
		}
	}
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		render(true)
	}
	override func resizeWithOldSuperviewSize(oldSize: NSSize) {
		super.resizeWithOldSuperviewSize(oldSize)
		render(true)
	}

	// MARK: -
	private let colorLayer = CALayer()
	private func render(layoutOnly: Bool) {
		checkAndReportFailureToDevelopers(layer != nil)
		guard let layer = layer else { return }
		if layoutOnly == false {
			if let backgroundColor = backgroundColor {
				colorLayer.backgroundColor = backgroundColor.CGColor
				layer.addSublayer(colorLayer)
			}
			else {
				colorLayer.removeFromSuperlayer()
				colorLayer.backgroundColor = nil
			}
		}
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		colorLayer.frame = layer.bounds
		CATransaction.commit()
	}
}




