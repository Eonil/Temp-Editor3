//
//  Debugger.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class Debugger {
        enum Event {
        	typealias Notification = EventNotification<Debugger,Event>
                case DidChangeState
        }

        enum State {
                case Ready
                case Running
        }

        private(set) var state: State = .Ready {
                didSet {
			Event.Notification(sender: self, event: .DidChangeState).broadcast()
                }
        }
}