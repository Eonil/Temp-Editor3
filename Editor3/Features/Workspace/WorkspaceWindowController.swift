//
//  WorkspaceWindowController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class WorkspaceWindowController: NSWindowController {

	convenience init() {
		// I don't know why, but configured "current appearance" disappears
		// at some point, and I have to set them again for every time I make
		// a new window...
		NSAppearance.setCurrentAppearance(NSAppearance(named: NSAppearanceNameVibrantDark))
		let newWindow = WorkspaceWindow()
		reconfigureWidnow(newWindow)
		self.init(window: newWindow)
		newWindow.display()
		newWindow.makeKeyAndOrderFront(self)
		let newWorkspaceViewController = WorkspaceViewController()
		workspaceViewController = newWorkspaceViewController
		contentViewController = newWorkspaceViewController
        }
        override init(window: NSWindow?) {
                assert(window != nil)
                preconditionAndReportFailureToDevelopers(window is WorkspaceWindow)
                super.init(window: window)
                installIfNeeded()
                render()
        }
        deinit {
                installer.deinstallIfNeeded {
                        NotificationUtility.deregister(self)
                }
        }

        @available(*,unavailable)
        required init?(coder: NSCoder) {
                fatalError("IB/SB are unsupported.")
        }

        // MARK: -
        weak var workspace: Workspace? {
                didSet {
                        render()
                }
        }

        // MARK: -
        private weak var workspaceViewController: WorkspaceViewController?
        private var installer = ViewInstaller()
	private func installIfNeeded() {
		assert(window != nil)
		guard let window = window else { return }
		installer.installIfNeeded {
			assert(window.appearance != nil)
			assert(window.appearance!.name == NSAppearanceNameVibrantDark)
			assert(NSAppearance.currentAppearance().name == NSAppearanceNameVibrantDark)
                        window.setFrame(CGRect(x: 100, y: 100, width: 100, height: 100), display: true)
//			window.restorationClass	=	_RestorationManager.self
//			window.releasedWhenClosed	=	false	// Trigger it's owner to release it.
//			_div.view.frame			= CGRect(origin: CGPoint.zero, size: _getMinSize())
			window.contentViewController	= workspaceViewController

                        NotificationUtility.register(self, [
                                NSWindowDidResizeNotification,
                                ], { [weak self] (n: NSNotification) -> () in
                                        self?.process(n)
                        })
                }
        }
}
extension WorkspaceWindowController {
        private func process(n: NSNotification) {
                guard n.object === window else { return }
                switch n.name {
                case NSWindowDidResizeNotification:
                        render()
                default:
                        reportToDevelopers("Received unexpected notification `\(n)`.")
                }
        }
        private func process(n: Workspace.Event.Notification) {
                guard n.sender === self else { return }
                switch n.event {
                case .DidChangeLocation:
                        MARK_unimplemented()
		case .DidChangeNavigationPaneSelection:
			break
//                case .RecoverableError(let error):
//                        preconditionAndReportFailureToDevelopers(window != nil)
//                        guard let window = window else { return }
//                        window.presentError(error as NSError)
                }
        }
}
extension WorkspaceWindowController {
        private func render() {
//              guard let window = window else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                guard let workspace = workspace else { return }
                guard let workspaceViewController = workspaceViewController else { return }
                workspaceViewController.workspace = workspace
        }
}

private final class WorkspaceWindow: NSWindow {
        override var canBecomeMainWindow: Bool {
                get {
                        return true
                }
        }
}

// MARK: -
private func reconfigureWidnow(window: NSWindow) {
	window.collectionBehavior	=	NSWindowCollectionBehavior.FullScreenPrimary
	window.styleMask		|=	NSClosableWindowMask
					|	NSResizableWindowMask
					|	NSMiniaturizableWindowMask
	window.titleVisibility		=	.Hidden

	window.setContentSize(_getMinSize())
	window.minSize			=	window.frame.size
	window.setFrame(_getInitialFrameForScreen(window.screen!, size: window.minSize), display: false)

	reconfigureWindowDarkMode(window)
}
private func reconfigureWindowDarkMode(window: NSWindow) {
//	window.titlebarAppearsTransparent	=	true
	window.appearance	=	NSAppearance(named: NSAppearanceNameVibrantDark)
	window.invalidateShadow()

	func makeDark(b:NSButton, _ alpha:CGFloat) {
		let	f	=	CIFilter(name: "CIColorMonochrome")!
		f.setDefaults()
//		f.setValue(CIColor(red: 0.5, green: 0.3, blue: 0.5, alpha: alpha), forKey: "inputColor")		//	I got this number accidentally, and I like this tone.
		f.setValue(CIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: alpha), forKey: "inputColor")
//
//		let	f1	=	CIFilter(name: "CIGammaAdjust")!
//		f1.setDefaults()
//		f1.setValue(0.3, forKey: "inputPower")
//
//		let	f2	=	CIFilter(name: "CIColorInvert")!
//		f2.setDefaults()

		b.contentFilters	=	[f]
	}
	makeDark(window.standardWindowButton(NSWindowButton.CloseButton)!, 1.0)
	makeDark(window.standardWindowButton(NSWindowButton.MiniaturizeButton)!, 1.0)
	makeDark(window.standardWindowButton(NSWindowButton.ZoomButton)!, 1.0)
}




private func _getInitialFrameForScreen(screen: NSScreen, size: CGSize) -> CGRect {
	let 	mid	=	CGPoint(x: screen.frame.midX, y: screen.frame.midY)
	let	f	=	CGRect(origin: mid, size: CGSize.zero)
	let	insets	=	NSEdgeInsets(top: -size.height/2, left: -size.width/2, bottom: -size.height/2, right: -size.width/2)
	let	f2	=	insets.inset(f)
	return	f2
}
private func _getMinSize() -> CGSize {
	return	CGSize(width: 600, height: 300)
}









