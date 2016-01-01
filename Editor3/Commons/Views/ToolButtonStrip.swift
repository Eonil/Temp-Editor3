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
			_deinstallToolButtons()
		}
		didSet {
			_installToolButtons()
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
			let	buttonSZs	=	toolButtons.map { $0.sizeThatFits(CGSize.zero) }
			let	totalW		=	buttonSZs.map { $0.width }.reduce(0, combine: +) + (interButtonGap * CGFloat(buttonSZs.count - 1))
			let	maxH		=	buttonSZs.map { $0.height }.reduce(0, combine: max)
			return	CGSize(width: totalW, height: maxH).round
		}
	}









	private var installer = ViewInstaller()

	private func _installToolButtons() {
		for b in toolButtons {
			addSubview(b)
		}
	}
	private func _deinstallToolButtons() {
		for b in toolButtons {
			b.removeFromSuperview()
		}
	}
}
private extension ToolButtonStrip {
	func render() {
		installer.installIfNeeded {
			_installToolButtons()
		}
		let	idealSZ		=	idealSize
		let	startingX	=	bounds.midX - (idealSZ.width / 2)
		var	x		=	startingX
		for i in 0..<toolButtons.count {
			let	button			=	toolButtons[i]
			let	y			=	bounds.midY - (button.frame.size.height / 2)
			toolButtons[i].frame.origin	=	CGPoint(x: round(x), y: round(y))

			assert(button.frame.width != 0, "Expects non-zero width.")
			x	+=	button.frame.width
			x	+=	interButtonGap
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








