//
//  AppKitExtensionsForAlertUtility.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/17.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

extension NSWindow {
	func runConfirmWithMessageText(messageText: String, informativeText: String? = nil, proceedButtonTitle: String, onProceed: ()->()) {
		let a = AlertUtility.confirmWithMessageText(messageText, informativeText: informativeText, proceedButtonTitle: proceedButtonTitle)
		a.beginSheetModalForWindow(self) { (response: NSModalResponse) in
			if response == NSAlertFirstButtonReturn {
				onProceed()
			}
		}
	}
}