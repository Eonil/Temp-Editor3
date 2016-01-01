//
//  CoreGraphicsExtensions.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import CoreGraphics
//import AppKit

extension CGRect {
	var round: CGRect {
		get {
			let	minX1	=	_round(minX)
			let	minY1	=	_round(minY)
			let	maxX1	=	_round(maxX)
			let	maxY1	=	_round(maxY)
			let	w1	=	maxX1 - minX1
			let	h1	=	maxY1 - minY1
			let	f	=	CGRect(x: minX1, y: minY1, width: w1, height: h1)
			return	f
		}
	}
//	func insetBy(edgeInsets: NSEdgeInsets) {
//	}
}
extension CGSize {
	var round: CGSize {
		get {
			return CGSize(width: _round(width), height: _round(height))
		}
	}
	var ceil: CGSize {
		get {
			return	CGSize(width: _ceil(width), height: _ceil(height))
		}
	}
}

// MARK: -
private func _round(a: CGFloat) -> CGFloat {
	return round(a)
}
private func _ceil(v: CGFloat) -> CGFloat {
	return	ceil(v)
}




























