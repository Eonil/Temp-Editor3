//
//  BoxTypeCoreGraphicsExtensions.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

extension BoxType where Scalar: CGFloatConvertibleBoxScalarType {
        func toCGRect() -> CGRect {
                return CGRect(
                        x: min.x.toCGFloat(),
                        y: min.y.toCGFloat(),
                        width: size.x.toCGFloat(),
                        height: size.y.toCGFloat())
        }
}
protocol CGFloatConvertibleBoxScalarType: BoxScalarType {
        init(_ value: CGFloat)
        func toCGFloat() -> CGFloat
}
extension CGFloat:CGFloatConvertibleBoxScalarType {
        init(_ value: CGFloat) {
                self = value
        }
        func toCGFloat() -> CGFloat {
                return self
        }
}
