//
//  BoxType.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

protocol BoxType {
        associatedtype Scalar: BoxScalarType
        var min: (x: Scalar, y: Scalar) { get }
        var max: (x: Scalar, y: Scalar) { get }
        var center: (x: Scalar, y: Scalar) { get }
	var size: (x: Scalar, y: Scalar) { get }
	init(min: (x: Scalar, y: Scalar), max: (x: Scalar, y: Scalar))
	init(center: (x: Scalar, y: Scalar), size: (x: Scalar, y: Scalar))
}
protocol BoxScalarType: FloatingPointType, FloatLiteralConvertible, IntegerLiteralConvertible {
        func + (a: Self, b: Self) -> Self
        func - (a: Self, b: Self) -> Self
        func * (a: Self, b: Self) -> Self
	func / (a: Self, b: Self) -> Self
}
extension BoxType {
        typealias Point = (x: Scalar, y: Scalar)
	init(center: (x: Scalar, y: Scalar), size: (x: Scalar, y: Scalar)) {
		let minX = (center.x - size.x / 2)
		let minY = (center.y - size.y / 2)
		let maxX = (center.x + size.x / 2)
		let maxY = (center.y + size.y / 2)
		self = Self(min: (minX, minY), max: (maxX, maxY))
	}
        var center: Point {
                get {
                        return (midOf(min.x, max.x), midOf(min.y, max.y))
                }
        }
        var size: Point {
                get {
                        return (max.x - min.x, max.y - min.y)
                }
        }
        
        func translatedBy(vector: (x: Scalar, y: Scalar)) -> Self {
		return Self(
                        min: min + vector,
                        max: max + vector)
        }
        func scaledBy(ratio: Scalar) -> Self {
                return Self(
                        min: min * ratio,
                        max: max * ratio)
        }
	/// Returns a new box with new size that resized around center.
	func resizedTo(size: (x: Scalar, y: Scalar)) -> Self {
		return Self(center: center,
		            size: size)
	}
        func splitAtX(x: Scalar) -> (min: Self, max: Self) {
                precondition(x >= min.x)
                precondition(x <= max.x)
                let a = Self(min: (min.x, min.y), max: (x, max.y))
                let b = Self(min: (x, min.y), max: (max.x, max.y))
                return (a,b)
        }
        func splitAtY(y: Scalar) -> (min: Self, max: Self) {
                precondition(y >= min.y)
                precondition(y <= max.y)
                let a = Self(min: (min.x, min.y), max: (max.x, y))
                let b = Self(min: (min.x, y), max: (max.x, max.y))
                return (a,b)
        }
        func splitAtCenterX() -> (min: Self, max: Self) {
                return splitAtX(center.x)
        }
        func splitAtCenterY() -> (min: Self, max: Self) {
                return splitAtY(center.y)
	}
	func minXDisplacedTo(x: Scalar) -> Self {
		precondition(x <= max.x)
		let a = (x, min.y)
		let b = max
		return Self(min: a, max: b)
	}
	func maxXDisplacedTo(x: Scalar) -> Self {
		precondition(x >= min.x)
		let a = min
		let b = (x, max.y)
		return Self(min: a, max: b)
	}
	func minYDisplacedTo(y: Scalar) -> Self {
		precondition(y <= max.y)
		let a = (min.x, y)
		let b = max
		return Self(min: a, max: b)
	}
	func maxYDisplacedTo(y: Scalar) -> Self {
		precondition(y >= min.y)
		let a = min
		let b = (max.x, y)
		return Self(min: a, max: b)
	}
	func minXDisplacedBy(x: Scalar) -> Self {
		return minXDisplacedTo(min.x + x)
	}
	func maxXDisplacedBy(x: Scalar) -> Self {
		return maxXDisplacedTo(max.x + x)
	}
	func minYDisplacedBy(y: Scalar) -> Self {
		return minYDisplacedTo(min.y + y)
	}
	func maxYDisplacedBy(y: Scalar) -> Self {
		return maxYDisplacedTo(max.y + y)
	}
}
extension BoxType {
        func minXEdge() -> Self {
                return splitAtX(min.x).min
        }
        func maxXEdge() -> Self {
                return splitAtX(max.x).max
        }
        func minYEdge() -> Self {
                return splitAtY(min.y).min
        }
        func maxYEdge() -> Self {
                return splitAtY(max.y).max
        }
}

















////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
private func + <S: BoxScalarType>(a: (x: S, y: S), b: (x: S, y: S)) -> (x: S, y: S) {
	return (a.x + b.x, a.y + b.y)
}
private func - <S: BoxScalarType>(a: (x: S, y: S), b: (x: S, y: S)) -> (x: S, y: S) {
        return (a.x - b.x, a.y - b.y)
}
private func * <S: BoxScalarType>(a: (x: S, y: S), b: S) -> (x: S, y: S) {
        return (a.x * b, a.y * b)
}
private func / <S: BoxScalarType>(a: (x: S, y: S), b: S) -> (x: S, y: S) {
        return (a.x / b, a.y / b)
}
private func midOf<S: BoxScalarType>(a: S, _ b: S) -> S {
	return a + ((b - a) / 2)
}









