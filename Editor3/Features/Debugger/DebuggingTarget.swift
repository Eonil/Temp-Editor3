//
//  DebuggingTarget.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/14.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import LLDBWrapper

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Debugging nodes are full wrappers. They hides wrapped LLDB objects completely.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



final class DebuggingTarget {
	enum Event {
		typealias Notification = EventNotification<DebuggingTarget,Event>
		case DidChangeState
	}
	enum State {
		case ReadyToStart
		case Paused
		case Running
		case Exited
	}

	// MARK: -
	init(LLDBTarget wrapped: LLDBTarget) {
		self.wrappedLLDBTarget = wrapped
	}

	var state: State = .ReadyToStart {
		didSet {
			guard state != oldValue else { return }
			Event.Notification(sender: self, event: .DidChangeState).broadcast()
		}
	}
	func launch() {

	}

	// MARK: -
	private let wrappedLLDBTarget: LLDBTarget
}

final class DebuggingProcess {
	enum Event {
		typealias Notification = EventNotification<DebuggingProcess,Event>
		case DidChangeState
	}
	enum State {
		case ReadyToStart
		case Paused
		case Running
		case Exited
	}

	// MARK: -
	init(LLDBProcess wrapped: LLDBProcess) {
		self.wrappedLLDBProcess = wrapped
	}
	var state: State = .ReadyToStart {
		didSet {
			guard state != oldValue else { return }
			Event.Notification(sender: self, event: .DidChangeState).broadcast()
		}
	}
	func allThreads() -> [DebuggingThread] {
		// TODO: Re-use object instance for same thread ID.
		return wrappedLLDBProcess.allThreads.map { DebuggingThread(LLDBThread: $0) }
	}
	/// Pauses
	func pause() {
		wrappedLLDBProcess.stop()
	}
	func resume() {
		wrappedLLDBProcess.`continue`()
	}
	func kill() {
		wrappedLLDBProcess.kill()
	}

	// MARK: -
	private let wrappedLLDBProcess: LLDBProcess
}

final class DebuggingThread {
	enum Event {
		typealias Notification = EventNotification<DebuggingThread,Event>
		case DidChangeState
	}
	enum State {
		case ReadyToStart
		case Paused
		case Running
		case Exited
	}

	init(LLDBThread: LLDBWrapper.LLDBThread) {
		self.wrappedLLDBThread = LLDBThread
	}
	var state: State = .ReadyToStart {
		didSet {
			guard state != oldValue else { return }
			Event.Notification(sender: self, event: .DidChangeState).broadcast()
		}
	}
	func resume() {
		wrappedLLDBThread.resume()
	}
	func pause() {
		wrappedLLDBThread.suspend()
	}
	func stepInto() {

	}

	// MARK: -
	private let wrappedLLDBThread: LLDBThread
}















