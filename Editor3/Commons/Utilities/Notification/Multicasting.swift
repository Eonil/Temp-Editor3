//
//  Multicasting.swift
//  DeepTree
//
//  Created by Hoon H. on 2015/11/25.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation

class MulticastStation<Parameter>: MulticastChannel<Parameter> {
	override init() {
	}
	func cast(parameter: Parameter) {
		_cast(parameter)
	}
	var onDidRegister: ((Callback)->())? {
		get {
			return _onDidRegister
		}
		set {
			_onDidRegister = newValue
		}
	}
	var onWillDeregister: ((Callback)->())? {
		get {
			return _onWillDeregister
		}
		set {
			_onWillDeregister = newValue
		}
	}
}

/// http://blog.scottlogic.com/2015/02/05/swift-events.html
class MulticastChannel<Parameter> {
	typealias Callback = (Parameter)->()

	private init() {
	}
	deinit {
		assert(_list.count == 0, "You MUST deregister all observers before this object `\(self)` dies.")
	}

	///

	var numberOfObservers: Int {
		get {
			return _list.count
		}
	}
	func containsObserver<T: AnyObject>(object: T) -> Bool {
		for atom in _list {
			if atom.identity == ObjectIdentifier(object) {
				return true
			}
		}
		return	false
	}
	func register<T: AnyObject>(object: T, _ instanceMethod: (T) -> Callback) {
		let invoke = { [weak object] (parameter: Parameter)->() in
			guard let object = object else {
				fatalError()
			}
			instanceMethod(object)(parameter)
		}
		register(ObjectIdentifier(object), invoke)
	}
	func deregister<T: AnyObject>(object: T) {
		deregister(ObjectIdentifier(object))
	}

	// MARK: -
	func register(identifier: ObjectIdentifier, _ function: Callback) {
		let atom = (identifier, function)
		_list.append(atom)
		_onDidRegister?(atom.1)
	}
	func deregister(identifier: ObjectIdentifier) {
		let range = _list.startIndex..<_list.endIndex
		for i in range.reverse() {
			let atom = _list[i]
			if atom.0 == identifier {
				_onWillDeregister?(atom.1)
				_list.removeAtIndex(i)
				return
			}
		}
		fatalError()
	}





	// MARK: -
	private typealias _Atom = (identity: ObjectIdentifier, invoke: Callback)
	private var _list = [_Atom]()
	private var _onDidRegister: ((Callback)->())?
	private var _onWillDeregister: ((Callback)->())?
	private func _cast(parameter: Parameter) {
		for atom in _list {
			atom.invoke(parameter)
		}
	}
}







