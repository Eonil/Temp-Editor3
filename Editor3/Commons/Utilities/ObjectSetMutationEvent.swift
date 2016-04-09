//
//  ObjectSetMutationEvent.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/09.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

/// Object set mutation events uses "will-remove" timing
/// to prevent unexpected object life-time extension.
enum ObjectSetMutationEvent<T: AnyObject> {
	case DidInsert(T)
	case WillRemove(T)
}