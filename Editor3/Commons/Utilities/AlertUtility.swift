//
//  AlertUtility.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/17.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

struct AlertUtility {
	static func confirmWithMessageText(messageText: String, informativeText: String? = nil, proceedButtonTitle: String) -> NSAlert {
		let a = NSAlert()
		a.alertStyle = .WarningAlertStyle
		a.messageText = messageText
		a.informativeText = informativeText ?? ""
		let b = a.addButtonWithTitle(proceedButtonTitle)
		b.keyEquivalent = "\r" // Return key. This makes default proceed button.
		let c = a.addButtonWithTitle("Cancel")
		c.keyEquivalent = "\u{1b}" // Escape key. This makes default cancel button.
		return a
	}
}
