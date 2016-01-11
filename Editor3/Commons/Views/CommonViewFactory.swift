//
//  CommonViewFactory.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

public struct CommonViewFactory {
        public static func instantiateScrollViewForNavigators() -> NSScrollView {
                return instanatiateCommonScrollViewForNavigators()
        }
        public static func instantiateScrollViewForCodeDisplayTextView() -> NSScrollView {
                return instanatiateCommonScrollViewForNavigators()
        }
	public static func instantiateOutlineViewForUseInSidebar() -> NSOutlineView {
		let c = NSTableColumn()
		let v = NSOutlineView()
		v.addTableColumn(c)
		v.rowSizeStyle				=	NSTableViewRowSizeStyle.Small		//<	This is REQUIRED. Otherwise, cell icon/text layout won't work.
		v.outlineTableColumn			=	c
		v.headerView				=	nil
		v.backgroundColor			=	NSColor.clearColor()
		v.selectionHighlightStyle		=	.SourceList
		v.draggingDestinationFeedbackStyle	=	.SourceList
		v.allowsEmptySelection			=	true
		v.allowsMultipleSelection		=	true
		v.focusRingType				=	.None
		return	v
        }
	public static func instantiateTextViewForCodeDisplay<T: NSTextView>() -> T {
		let v = T()
		v.verticallyResizable			=	true
		v.horizontallyResizable			=	true
//		v.drawsBackground			=	false
		v.backgroundColor			=	EditorCodeBackgroundColor
		v.font					=	_codeFont()
		v.typingAttributes			=	[
			NSFontAttributeName		:	_codeFont(),
//			NSBackgroundColorAttributeName	:	EditorCodeBackgroundColor,
			NSForegroundColorAttributeName	:	EditorCodeForegroundColor,
		]
		v.selectedTextAttributes		=	[
			NSFontAttributeName		:	_codeFont(),
			NSBackgroundColorAttributeName	:	EditorSelectedCodeBackgroundColor,
			NSForegroundColorAttributeName	:	EditorSelectedCodeForegroundColor,
		]
		v.textContainer!.widthTracksTextView	=	true
		v.textContainer!.heightTracksTextView	=	false
		v.textContainer!.containerSize		=	CGSize(width: CGFloat.max, height: CGFloat.max)
		return	v
	}
}









private func instanatiateCommonScrollViewForNavigators() -> NSScrollView {
        let v = NSScrollView()
        v.hasHorizontalScroller	=	true
        v.hasVerticalScroller	=	true
        v.drawsBackground	=	false
        return v
}
private func _codeFont() -> NSFont {
	return	CommonFont.codeFontOfSize(NSFont.systemFontSize())
}








