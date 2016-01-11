//
//  CommonViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Provides a common feature set for a view-controller.
/// Removes NIB shits.
///
/// This also solves "late layout" of `NSViewController`.
/// In some cases, `NSViewController.viewDidLayout` get called
/// too later (out of sync), and as a result, view layout looks
/// weirdy slides. By explicitly routing `NSView.resizeSubviewsWithOldSize`
/// signal to view controller, we can remove such graphical glitches.
/// To get use this solution, override `layoutSubcomponents` method to get
/// view resize signal.
class CommonViewController: NSViewController {

	/// The designated initializer.
	init() {
		super.init(nibName: nil, bundle: nil)!
		let v	= CommonViewWithViewInstallationEventRouting(frame: CGRect(x: 0, y: 0, width: 1024, height: 1024))	//	Initial frame size must be non-zero size. Otherwise AppKit will be broken.
		v.owner	= self
		view	= v
		if _calledViewDidLoadOnceFlag == false {
			viewDidLoad()
		}
	}

	// MARK: -

	@available(*,unavailable)
	override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		assert(nibNameOrNil == nil)
		assert(nibBundleOrNil == nil)
		preconditionAndReportFailureToDevelopers(nibNameOrNil == nil)
		preconditionAndReportFailureToDevelopers(nibBundleOrNil == nil)
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	@available(*,unavailable)
	required init?(coder: NSCoder) {
		fatalError("IB/SB are unsupported.")
//		super.init(coder: coder)
	}

        // MARK: -
        override func loadView() {
		let v = CommonView()
                self.view = v
        }

	// MARK: -
	func installSubcomponents() {}
	func deinstallSubcomponents() {}
	func layoutSubcomponents() {}

	// MARK: -
	@available(*, unavailable, message="This property is not supported.")
	override var representedObject: AnyObject? {
		get {
			fatalError("This property is not supported.")
		}
		set {
			fatalError("This property is not supported.")
		}
	}
//	override func loadView() {
//		let	v	=	_CommonViewWithViewInstallationEventRouting(frame: CGRect.zeroRect)
//		v.owner		=	self
//		super.view	=	v
//	}
	override func viewDidLoad() {
		super.viewDidLoad()
		assert(_calledViewDidLoadOnceFlag == false)
		_calledViewDidLoadOnceFlag = true
//		view.addSubview(_installationEventRoutingView)
		view.identifier = "(of: \(self))"
	}
	@available(*,unavailable,message="Do not use this method to take view resizing event. This sometimes get called asynchronously which triggers a view layout tearing. Use `layoutSubcomponents` method instead of.")
	override func viewDidLayout() {
		super.viewDidLayout()
	}

	// MARK: -
	private var _calledViewDidLoadOnceFlag = false
	private func _install() {
		installSubcomponents()
	}
	private func _deinstall() {
		deinstallSubcomponents()
	}
	private func _layout() {
		layoutSubcomponents()
	}
}

















final class CommonViewWithViewInstallationEventRouting: CommonView {
	weak var owner: CommonViewController?
	override func installSubcomponents() {
		super.installSubcomponents()
		owner!._install()
	}
	override func deinstallSubcomponents() {
		owner!._deinstall()
		super.deinstallSubcomponents()
	}
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		owner!._layout()
	}
}














