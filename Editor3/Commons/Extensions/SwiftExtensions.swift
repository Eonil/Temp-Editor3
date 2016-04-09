//
//  SwiftExtensions.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/05.
//  Copyright © 2016 Eonil. All rights reserved.
//

// MARK: - Operators

/// Strongly typed reference equality comparison.
infix operator ==== {}
/// Performs strongly typed reference equality comparison.
func ==== <T: AnyObject> (a: T, b: T) -> Bool {
	return a === b
}
/// Performs strongly typed reference equality comparison.
func ==== <T: AnyObject> (a: T?, b: T) -> Bool {
	return a === b
}
/// Performs strongly typed reference equality comparison.
func ==== <T: AnyObject> (a: T, b: T?) -> Bool {
	return a === b
}
/// Performs strongly typed reference equality comparison.
func ==== <T: AnyObject> (a: T?, b: T?) -> Bool {
	return a === b
}

/// Strongly typed reference inequality comparison.
infix operator !=== {}
/// Performs strongly typed reference equality comparison.
func !=== <T: AnyObject> (a: T, b: T) -> Bool {
	return a !== b
}
/// Performs strongly typed reference equality comparison.
func !=== <T: AnyObject> (a: T?, b: T) -> Bool {
	return a !== b
}
/// Performs strongly typed reference equality comparison.
func !=== <T: AnyObject> (a: T, b: T?) -> Bool {
	return a !== b
}
/// Performs strongly typed reference equality comparison.
func !=== <T: AnyObject> (a: T?, b: T?) -> Bool {
	return a !== b
}

////@available(*,unavailable,message="Untyped reference equality comparison disallowed.")
////func === (a: AnyObject, b: AnyObject) -> Bool {
////	return ObjectIdentifier(a) == ObjectIdentifier(b)
////}
//@available(*,unavailable,message="Untyped reference equality comparison disallowed.")
//func === <T: AnyObject, U: AnyObject> (a: T, b: U) -> Bool {
//	return ObjectIdentifier(a) == ObjectIdentifier(b)
//}
//
/////// Only strongly typed reference equality comparisons are allowed.
////func === <T: AnyObject> (a: T, b: T) -> Bool {
////	return ObjectIdentifier(a) == ObjectIdentifier(b)
////}
//
//func a () {
//	class A {
//	}
//	class B {}
//	let a = A()
//	let b = B()
//	let ok = a === b
//}