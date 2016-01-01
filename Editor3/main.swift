//
//  main.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

autoreleasepool {
        let driver = Driver()
        let delegate = AppDelegate()
        let app = NSApplication.sharedApplication()
        app.delegate = delegate
	app.run()
}