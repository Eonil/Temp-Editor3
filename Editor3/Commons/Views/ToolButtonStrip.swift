//
//  ToolButtonStrip.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/11/07.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit

//class ToolButton: NSButton, IdeallySizableType {
//	var idealSize: CGSize = CGSize.zero
//}
final class ToolButtonStrip: NSView {

	var toolButtons: [CommonView] = [] {
		willSet {
			deinstallToolButtons()
		}
		didSet {
			installToolButtons()
			render()
		}
	}
	var interButtonGap: CGFloat = 0 {
		didSet {
			render()
		}
	}
	var idealSize: CGSize {
		get {
			let buttonSZs = toolButtons.map { $0.sizeThatFits(CGSize.zero) }
			let totalW = buttonSZs.map { $0.width }.reduce(0, combine: +) + (interButtonGap * CGFloat(buttonSZs.count - 1))
			let maxH = buttonSZs.map { $0.height }.reduce(0, combine: max)
			return CGSize(width: totalW, height: maxH).round
		}
	}

	override func resizeSubviewsWithOldSize(oldSize: NSSize) {
		super.resizeSubviewsWithOldSize(oldSize)
		render()
	}

}
private extension ToolButtonStrip {
	func installToolButtons() {
		for b in toolButtons {
			addSubview(b)
		}
	}
	func deinstallToolButtons() {
		for b in toolButtons {
			b.removeFromSuperview()
		}
	}
	func render() {
		let idealSZ = idealSize
		let startingX =	bounds.midX - (idealSZ.width / 2)
		var x =	startingX
		for i in 0..<toolButtons.count {
			let button = toolButtons[i]
			let y = bounds.midY - (button.frame.size.height / 2)
			toolButtons[i].frame.origin = CGPoint(x: round(x), y: round(y))

			assert(button.frame.width != 0, "Expects non-zero width.")
			x += button.frame.width
			x += interButtonGap
		}
	}
}



//extension NSView {
//	/// Movement from parent's bounds center.
//	var translation: CGPoint {
//		get {
//
//		}
//	}
//}


//protocol IdeallySizableType {
//	var idealSize: CGSize { get }
//}








