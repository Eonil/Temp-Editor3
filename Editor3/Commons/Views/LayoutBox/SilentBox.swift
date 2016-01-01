//
//  SilentBox.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct SilentBox: BoxType {
        typealias Scalar = CGFloat
        typealias Point = (x: Scalar, y: Scalar)
        private var box: Box
        init(min: (x: Scalar, y: Scalar), max: (x: Scalar, y: Scalar)) {
                self.box = Box(min: min, max: max)
        }
        var min: Point {
                get {
                        return box.min
                }
        }
        var max: Point {
                get {
                        return box.max
                }
        }
}
// MARK: - Overridins
extension SilentBox {
	func splitAtX(x: Scalar) -> (min: SilentBox, max: SilentBox) {
		guard x >= min.x else { return splitAtX(min.x) }
		guard x <= max.x else { return splitAtX(max.x) }
		let (a,b) = box.splitAtX(x)
		return (a.toSilentBox(), b.toSilentBox())
	}
	func splitAtY(y: Scalar) -> (min: SilentBox, max: SilentBox) {
		guard y >= min.y else { return splitAtY(min.y) }
		guard y <= max.y else { return splitAtY(max.y) }
		let (a,b) = box.splitAtY(y)
		return (a.toSilentBox(), b.toSilentBox())
	}
	func minXDisplacedTo(x: Scalar) -> SilentBox {
		guard x <= max.x else { return minXDisplacedTo(max.x) }
		return box.minXDisplacedTo(x).toSilentBox()
	}
	func maxXDisplacedTo(x: Scalar) -> SilentBox {
		guard x >= min.x else { return maxXDisplacedTo(min.x) }
		return box.maxXDisplacedTo(x).toSilentBox()
	}
	func minYDisplacedTo(y: Scalar) -> SilentBox {
		guard y <= max.y else { return minYDisplacedTo(max.y) }
		return box.minYDisplacedTo(y).toSilentBox()
	}
	func maxYDisplacedTo(y: Scalar) -> SilentBox {
		guard y >= min.y else { return maxYDisplacedTo(min.y) }
		return box.maxYDisplacedTo(y).toSilentBox()
	}
}
extension Box {
        func toSilentBox() -> SilentBox {
                return SilentBox(min: min, max: max)
        }
}



















