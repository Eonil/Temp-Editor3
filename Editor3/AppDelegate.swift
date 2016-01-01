//
//  AppDelegate.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationDidFinishLaunching(aNotification: NSNotification) {
                Driver.theDriver!.test1()
        }
        func applicationWillTerminate(aNotification: NSNotification) {
        }
}

