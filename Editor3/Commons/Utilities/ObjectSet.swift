//
//  ObjectSet.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct ObjectSet<T: AnyObject>: SequenceType {
        var count: Int {
                get {
                        return set.count
                }
        }
        var first: T? {
                get {
                        return set.first?.object
                }
        }
        func generate() -> AnyGenerator<T> {
		var g = set.generate()
                return anyGenerator {
			return g.next()?.object
		}
        }
        mutating func insert(member: T) {
		set.insert(Wrapper(object: member))
        }
        mutating func remove(member: T) -> T? {
                return set.remove(Wrapper(object: member))?.object
        }

        private var set = Set<Wrapper<T>>()
}

private struct Wrapper<T: AnyObject>: Hashable {
	var object: T
        var hashValue: Int {
                get {
                        return ObjectIdentifier(object).hashValue
                }
        }
}

private func == <T: AnyObject>(a: Wrapper<T>, b: Wrapper<T>) -> Bool {
        return a.object === b.object
}