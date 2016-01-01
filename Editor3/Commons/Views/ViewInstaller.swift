//
//  ViewInstaller.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct ViewInstaller {
        private(set) var isInstalled = false
        mutating func installIfNeeded(@noescape install: ()->()) {
                if isInstalled == false {
                        install()
                        isInstalled = true
                }
        }
        mutating func deinstallIfNeeded(@noescape deinstall: ()->()) {
                if isInstalled == true {
                        deinstall()
                        isInstalled = false
                }
        }
}