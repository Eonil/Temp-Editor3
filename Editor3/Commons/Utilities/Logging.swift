//
//  Logging.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

func debugLog<T>(@autoclosure value: ()->T, file: String = #file, line: Int = #line) {
        assert({ () -> Bool in
                let name = NSURL(fileURLWithPath: file).lastPathComponent ?? "????"
                let message = "\(name) (\(line)): \(value())"
                print(message)
                return true
        }())
}

