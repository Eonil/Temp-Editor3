//
//  Box.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

extension CGFloat: BoxScalarType {
}
struct Box: BoxType {
        typealias Scalar = CGFloat
        typealias Point = (x: Scalar, y: Scalar)
        init(min: Point, max: Point) {
                precondition(min.x <= max.x)
                precondition(min.y <= max.y)
                self.min = min
                self.max = max
        }
        var min: Point
        var max: Point
}
extension CGRect {
        func toBox() -> Box {
                return Box(center: (midX, midY), size: (width, height))
        }
}


