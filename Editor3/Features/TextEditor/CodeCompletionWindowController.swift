//
//  CodeCompletionWindowController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class CodeCompletionWindowController: NSWindowController {
        convenience init() {
                let newCodeCompletionViewController = CodeCompletionViewController()
                let newWindow = CodeCompletionWindow(contentViewController: newCodeCompletionViewController)
                newWindow.styleMask &= ~NSClosableWindowMask
                newWindow.styleMask &= ~NSTitledWindowMask
                newWindow.styleMask &= ~NSMiniaturizableWindowMask
		newWindow.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
		self.init(window: newWindow) // Instance of `self` can be changed at here.
		codeCompletionViewController = newCodeCompletionViewController // So we set it to instance var later.
                render()
        }

        weak var codeCompletion: CodeCompletion? {
                didSet {
                        render()
                }
        }
        private(set) var codeCompletionViewController: CodeCompletionViewController?

	/// Whether the window is displayed or not.
        private(set) var isFloating: Bool = false

        /// Floats window around rect in screen space.
	/// You can call this again just to adjust window position.
        func floatAroundRectInScreenSpace(rectInScreenSpace: CGRect) {
                assert(window != nil)
                guard let window = window else { return }
                render()
		let rectInScreen = rectInScreenSpace
			.toBox()
			.toSilentBox()
			.minYEdge()
			.resizedTo((300,100))
			.translatedBy((+150,-50))
			.toCGRect()
                window.setFrame(rectInScreen, display: true)
		window.orderFront(self)
                isFloating = true
                window.makeKeyWindow()
        }
        func sink() {
                assert(window != nil)
                guard let window = window else { return }
                window.orderOut(self)
                isFloating = false
        }

        // MARK: -
        private var installer = ViewInstaller()
        private func process(n: NSNotification) {
		render()
        }
        private func render() {
		installer.installIfNeeded {
			assert(window != nil)
			guard let window = window else { return }
			let newWindowLevel = CGWindowLevelKey.FloatingWindowLevelKey.rawValue
			guard IntMax(newWindowLevel) <= IntMax(Int.max) else { return }
			guard IntMax(newWindowLevel) >= IntMax(Int.min) else { return }
			// Make title-less round cornered window with shadow.
			do {
				window.backgroundColor	=	NSColor.whiteColor()
				window.opaque		=	false
				window.hasShadow	=	true
				window.styleMask	=	NSResizableWindowMask
					|	NSTitledWindowMask
					|	NSFullSizeContentViewWindowMask
				window.movableByWindowBackground	=	true
				window.titlebarAppearsTransparent	=	true
				window.titleVisibility			=	.Hidden
				window.showsToolbarButton		=	false
				window.standardWindowButton(.FullScreenButton)?.hidden	=	true
				window.standardWindowButton(.MiniaturizeButton)?.hidden	=	true
				window.standardWindowButton(.CloseButton)?.hidden	=	true
				window.standardWindowButton(.ZoomButton)?.hidden	=	true
			}
			window.level = Int(newWindowLevel)
			window.delegate = self
			NotificationUtility.register(self, [
				NSWindowDidResizeNotification,
				], { [weak self] (n: NSNotification) -> () in
					self?.process(n)
				})
			window.makeFirstResponder(codeCompletionViewController)
			assert(window.firstResponder === codeCompletionViewController)
		}

                assert(window != nil)
                assert(codeCompletionViewController != nil)
                guard let codeCompletionViewController = codeCompletionViewController else { return }
                codeCompletionViewController.codeCompletion = codeCompletion
        }
}
extension CodeCompletionWindowController: NSWindowDelegate {
        func windowDidResignKey(notification: NSNotification) {
                sink()
        }
}

private final class CodeCompletionWindow: NSWindow {
//        override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, `defer` flag: Bool) {
//                super.init(contentRect: contentRect, styleMask: styleMask, backing: bufferingType, `defer`: flag)
//        }
//        required init?(coder: NSCoder) {
//                fatalError("IB/SB are unsupported.")
//        }
        override var canBecomeMainWindow: Bool {
                get {
                        return false
                }
        }
        override var canBecomeKeyWindow: Bool {
                get {
                        return false
                }
        }
}



















