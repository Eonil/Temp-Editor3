//
//  Assertions.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

func assertMainThread() {
	assert(NSThread.isMainThread() == true)
}
func assertNonMainThread() {
        assert(NSThread.isMainThread() == false)
}