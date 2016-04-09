//
//  ObjectSet.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct ObjectSet<T: AnyObject>: SequenceType {

	init() {
		self.wrappedObjectSet = []
	}
        var count: Int {
                get {
                        return wrappedObjectSet.count
                }
        }
        var first: T? {
                get {
                        return wrappedObjectSet.first?.object
                }
        }
        func generate() -> AnyGenerator<T> {
		var g = wrappedObjectSet.generate()
                return AnyGenerator {
			return g.next()?.object
		}
        }
        mutating func insert(member: T) {
		wrappedObjectSet.insert(Wrapper(object: member))
        }
        mutating func remove(member: T) -> T? {
                return wrappedObjectSet.remove(Wrapper(object: member))?.object
        }
	func union(other: ObjectSet) -> ObjectSet {
		return ObjectSet(wrappedObjectSet: wrappedObjectSet.union(other.wrappedObjectSet))
	}
	func subtract(otherSet: ObjectSet) -> ObjectSet {
		return ObjectSet(wrappedObjectSet: wrappedObjectSet.subtract(otherSet.wrappedObjectSet))
	}

        private var wrappedObjectSet: Set<Wrapper<T>>
	private init(wrappedObjectSet: Set<Wrapper<T>>) {
		self.wrappedObjectSet = wrappedObjectSet
	}
}
extension ObjectSet {
	func differencesFrom(anotherSet: ObjectSet) -> (insertedObjects: ObjectSet, removedObjects: ObjectSet) {
		let insertedObjects = self.subtract(anotherSet)
		let removedObjects = anotherSet.subtract(self)
		return (insertedObjects, removedObjects)
	}
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









