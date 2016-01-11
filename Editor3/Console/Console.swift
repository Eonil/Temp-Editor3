//
//  Console.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/05.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class Console {
	enum Event {
		typealias Notification = EventNotification<Console,Event>
		case DidChangeContent
	}
	var content: String = "" {
		didSet {
			Event.Notification(sender: self, event: .DidChangeContent).broadcast()
		}
	}

//	private func process(n: 
}

































