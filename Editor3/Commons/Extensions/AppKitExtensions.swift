//
//  AppKitExtensions.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

//extension NSView {
//        func constraintFrameToView(targetView: NSView) {
//                assert(translatesAutoresizingMaskIntoConstraints == false)
//                leftAnchor.constraintEqualToAnchor(targetView.leftAnchor).active = true
//                rightAnchor.constraintEqualToAnchor(targetView.rightAnchor).active = true
//                topAnchor.constraintEqualToAnchor(targetView.topAnchor).active = true
//                bottomAnchor.constraintEqualToAnchor(targetView.bottomAnchor).active = true
//        }
//}

extension NSViewController {
        func addChildViewAndControllerImmediately(childViewController: NSViewController) {
                assert(childViewController.parentViewController === nil)
                assert(childViewController.view.superview === nil)
                addChildViewController(childViewController)
                view.addSubview(childViewController.view)
        }
        func removeChildViewAndControllerImmediately(childViewController: NSViewController) {
                assert(childViewController.parentViewController === self)
                assert(childViewController.view.superview === view)
                childViewController.view.removeFromSuperview()
                childViewController.removeFromParentViewController()
        }
}
extension NSEdgeInsets {
	func inset(rect: NSRect) -> NSRect {
		let	rect1	=	CGRect(
			x	:	rect.origin.x + left,
			y	:	rect.origin.y + bottom,
			width	:	rect.width - (left + right),
			height	:	rect.height - (top + bottom))

		return	rect1
	}
}
prefix func - (a: NSEdgeInsets) -> NSEdgeInsets {
	return NSEdgeInsets(top: -a.top, left: -a.left, bottom: -a.bottom, right: -a.right)
}