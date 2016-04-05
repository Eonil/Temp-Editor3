//
//  CommonFont.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

public struct CommonFont {
	public static func codeFontOfSize(size: CGFloat) -> NSFont {
		return NSFont(name: "Menlo", size: size)!
	}
	public static let codeFontWithSystemSize = CommonFont.codeFontOfSize(NSFont.systemFontSize())
}