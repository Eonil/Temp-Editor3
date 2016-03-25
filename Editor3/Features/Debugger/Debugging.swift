//
//  Debugger.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import LLDBWrapper

final class Debugger {
        enum Event {
        	typealias Notification = EventNotification<Debugger,Event>
                case DidChangeState
		case DidChangeSelectedThread
		case DidChangeSelectedFrame
        }

        enum State {
                case Ready
		case Running
		case Pause
		/// Process exited.
		case Done
        }

        private(set) var state: State = .Ready {
                didSet {
			if state != oldValue {
				Event.Notification(sender: self, event: .DidChangeState).broadcast()
			}
                }
        }



	var selectedTarget: DebuggingTarget? {
		didSet {
			guard selectedTarget !== oldValue else { return }
		}
	}
	var selectedThread: LLDBThread? {
		didSet {
			guard selectedThread !== oldValue else { return }
			Event.Notification(sender: self, event: .DidChangeSelectedThread).broadcast()
		}
	}
	var selectedFrame: LLDBFrame? {
		didSet {
			guard selectedThread !== oldValue else { return }
			Event.Notification(sender: self, event: .DidChangeSelectedFrame).broadcast()
		}
	}
//	var selectedValue: LLDBValue? {
//
//	}
}


















