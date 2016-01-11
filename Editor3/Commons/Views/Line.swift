//
//  Line.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/11/08.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Draws thinnest clear line at specified position.
final class Line: CommonView {

	enum Position {
		case MaxX
		case MinX
		case MinY
		case MaxY
	}

	var lineColor: NSColor = NSColor.blackColor() {
		didSet {
			render()
		}
	}
	var position: Position = .MinY {
		didSet {
			render()
		}
	}
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		render()
	}

	// MARK: -
	private let lineShapeView = ColorView()
	private var installer = ViewInstaller()
	private func render() {
		installer.installIfNeeded {
			addSubview(lineShapeView)
		}
		let lineBox: SilentBox = {
			let box = bounds.toBox().toSilentBox()
			switch position {
			case .MinX: return box.minXEdge().maxXDisplacedBy(+1)
			case .MaxX: return box.maxXEdge().minXDisplacedBy(-1)
			case .MinY: return box.minYEdge().maxYDisplacedBy(+1)
			case .MaxY: return box.maxYEdge().minYDisplacedBy(-1)
			}
		}()
		lineShapeView.frame = lineBox.toCGRect()
		lineShapeView.backgroundColor = lineColor
	}
}





















