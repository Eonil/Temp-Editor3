//
//  OwnerIdentifier.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct OwnerIdentifier<T: AnyObject> {
        init(_ owner: T) {
		self.identifier = ObjectIdentifier(owner)
        }

        private let identifier: ObjectIdentifier
}

func == <T: AnyObject> (a: OwnerIdentifier<T>, b: OwnerIdentifier<T>) -> Bool {
	return a.identifier == b.identifier
}
func == <T: AnyObject> (a: OwnerIdentifier<T>, b: T) -> Bool {
	return a == OwnerIdentifier(b)
}
func == <T: AnyObject> (a: T, b: OwnerIdentifier<T>) -> Bool {
	return OwnerIdentifier(a) == b
}