//
//  ConsoleViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/05.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class ConsoleViewController: CommonViewController {

	deinit {
		installer.deinstallIfNeeded {
			Console.Event.Notification.deregister(self)
		}
	}

	weak var console: Console? {
		didSet {
			render()
		}
	}

	override func installSubcomponents() {
		super.installSubcomponents()
		render()
	}
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		render()
	}

	// MARK: -
	private let scrollView = CommonViewFactory.instantiateScrollViewForCodeDisplayTextView()
	private let textView = CommonViewFactory.instantiateTextViewForCodeDisplay()
	private var installer = ViewInstaller()
	private func process(n: Console.Event.Notification) {
		guard n.sender ==== console else { return }
		render()
	}
	private func render() {
		installer.installIfNeeded {
			scrollView.documentView = textView
			view.addSubview(scrollView)
			Console.Event.Notification.register(self, self.dynamicType.process)
		}
		scrollView.frame = view.bounds
		textView.string = console?.content ?? ""
	}
}



























