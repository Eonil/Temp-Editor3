//
//  NavigatorCommonViewFactory.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

struct NavigatorCommonViewFactory {
	static func instantiateNodeTextField() -> NSTextField {
		let v			=	NSTextField()
		v.bezeled		=	false
		v.backgroundColor	=	NSColor.clearColor()
//		v.maximumNumberOfLines	=	1	//<	Only for 10.11+.
		v.lineBreakMode		=	NSLineBreakMode.ByTruncatingTail
		return v
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
private func instanatiateCommonScrollViewForNavigators() -> NSScrollView {
	let v = NSScrollView()
	v.hasHorizontalScroller	=	true
	v.hasVerticalScroller	=	true
	v.drawsBackground	=	false
	return v
}

























