//
//  ShellCommandExecutor.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class ShellCommandExecutor {
	// MARK: -
	init() {
		transition.onEvent = { [weak self] in
			guard let ssss = self else { return }
			ssss.onEvent?($0)
		}
	}
	deinit {
		cleanup()
	}

	var onEvent: (Event->())?

	var state: State {
		get {
			return transition.state
		}
	}

	// MARK: -
	private let transition		=	Transition(State.Ready, ShellCommandExecutor.defaultTransitionRules())
	private let shell		=	ShellTaskExecutionController()
	private var stdoutUTF8Decoder	=	_UTF8Decoder()
	private var stderrUTF8Decoder	=	_UTF8Decoder()
	private var isShellLaunched	=	AtomicBool(false)
	private var isShellTerminated	=	AtomicBool(false)
	private var stdoutEOF		=	AtomicBool(false)
	private var stderrEOF		=	AtomicBool(false)
	private let waitSema		=	dispatch_semaphore_create(0)!
	private var stateShouldBeDone	=	AtomicBool(false)

}
extension ShellCommandExecutor {

	enum State {
		case Ready
		case Running
		case Cleaning		//<	Death declared, but not yet actually dead.
		case Done
	}

	enum Event {
		case Launch		//<	Ready -> Running
		case Clean		//<	Running -> Cleaning
		case Exit		//<	Cleaning -> Done

		/// It's guaranteed that this won't be called anymore since `onTermination` has been called.
		case StandardOutput(String)
		/// It's guaranteed that this won't be called anymore since `onTermination` has been called.
		case StandardError(String)
	}

	private static func defaultTransitionRules() -> [Transition<State, Event>.Rule] {
		return	[
			(.Ready,	.Running,	.Launch),
			(.Running,	.Cleaning,	.Clean),
			(.Cleaning,	.Done,		.Exit),
		]
	}
}
extension ShellCommandExecutor {
	func launch(workingDirectoryPath: String) {
		assertMainThread()
		precondition(transition.state == .Ready)
		transition.state = .Running
		shell.terminationHandler = { [weak self] in
			dispatchToNonMainQueueAsynchronously { [weak self] in
				assert(self != nil)
				preconditionAndReportFailureToDevelopers(self != nil)
				self?.onShellTerminationOnNonMainThread()
			}
		}
		shell.launch(workingDirectoryPath: workingDirectoryPath)
		dispatchToNonMainQueueAsynchronously { [weak self] in
			assert(self != nil)
			preconditionAndReportFailureToDevelopers(self != nil)
			self?.runReadingStandardOutputOnNonMainThread()
		}
		dispatchToNonMainQueueAsynchronously { [weak self] in
			assert(self != nil)
			preconditionAndReportFailureToDevelopers(self != nil)
			self?.runReadingStandardErrorOnNonMainThread()
		}
	}
	/// Blocks calling thread (main thread) until `transition.state == .Done`.
	/// `transition.state == .Done` when this function returns.
	/// `Event.Done` will be called right after this function returned.
	func wait() {
		assertMainThread()
		dispatch_semaphore_wait(waitSema, DISPATCH_TIME_FOREVER)
		if stateShouldBeDone.state {
			if transition.state == .Running {
				transition.state = .Cleaning
				transition.state = .Done
				assert(onEvent != nil)
				onEvent?(.Exit)
			}
		}
	}
	func execute(command: String) {
		assertMainThread()
		precondition(transition.state == .Running, "You can execute only on executor that is in running state.")
		shell.standardInput.writeUTF8String(command)
		shell.standardInput.writeUTF8String("\n")
	}
	func terminate() {
		assertMainThread()
		precondition(transition.state == .Running)
		transition.state = .Cleaning
		shell.terminate()
	}
	func kill() {
		assertMainThread()
		precondition(transition.state == .Running)
		transition.state = .Cleaning
		shell.kill()
	}
}
extension ShellCommandExecutor {
	private func fireEvent(event: Event) {
		assert(onEvent != nil)
		onEvent?(event)
	}
	private func runReadingStandardOutputOnNonMainThread() {
		assertNonMainThread()
		while true {
			var s = ""
			let r = _readBytes(_BUFFER_SIZE_IN_BYTES, fromFileHandle: shell.standardOutput)
			switch r {
			case .Bytes(let bs):
				for b in bs {
					s.appendContentsOf(stdoutUTF8Decoder.push(b))
				}
				dispatchToMainQueueAsynchronously { [weak self] in
					self?.fireEvent(.StandardOutput(s))
				}
				continue

			case .EOF:
				break
			}
			break
		}
		dispatchToMainQueueAsynchronously { [weak self] in
			self!.stdoutEOF.state = true
		}
	}
	private func runReadingStandardErrorOnNonMainThread() {
		assertNonMainThread()
		while true {
			var s = ""
			let r = _readBytes(_BUFFER_SIZE_IN_BYTES, fromFileHandle: shell.standardError)
			switch r {
			case .Bytes(let bs):
				for b in bs {
					s.appendContentsOf(stderrUTF8Decoder.push(b))
				}
				dispatchToMainQueueAsynchronously { [weak self] in
					self?.fireEvent(.StandardError(s))
				}
				continue

			case .EOF:
				break
			}
			break
		}
		dispatchToMainQueueAsynchronously { [weak self] in
			self!.stderrEOF.state	=	true
		}
	}
	private func onShellTerminationOnNonMainThread() {
		assertNonMainThread()
		dispatchToNonMainQueueAsynchronously { [weak self] in
			// We cannot roun-trip to main thread because it can be blocked by `wait` at this point.
			// So, we made all flags atomic.
			self!.isShellTerminated.state = true
			if self!.stdoutEOF.state && self!.stderrEOF.state {
				self!.stateShouldBeDone.state = true //< We need this because main thread can be blocked by `wait` call.
				dispatch_semaphore_signal(self!.waitSema)
				dispatchToMainQueueAsynchronously { [weak self] in
					if self!.transition.state == .Running {
						self!.transition.state = .Cleaning
						self!.transition.state = .Done
					}
				}
			}
			else {
				// Wait more...
				dispatchToNonMainQueueAsynchronously { [weak self] in
					dispatchToSleepAndContinueInNonMainQueue(0.1) { [weak self] in
						assert(self != nil)
						preconditionAndReportFailureToDevelopers(self != nil)
						self?.onShellTerminationOnNonMainThread()
					}
				}
			}
		}
	}
	private func cleanup() {
		// Buffer state can be dirty if the remote process exited by crash.
		let MSG = "You're responsible to keep this object alive until this remote shell exits."
		assert(isShellTerminated.state == true, MSG)
		assert(stdoutEOF.state == true, MSG)
		assert(stderrEOF.state == true, MSG)
	}
}















private struct _UTF8Decoder {
	mutating func push(byte: UInt8) -> String {
		var	buffer	=	String()
		var	g	=	GeneratorOfOne(byte)
		while true {
			switch utf8.decode(&g) {
			case .EmptyInput:
				utf8	=	UTF8()
				return	buffer

			case .Error:
				return	""

			case .Result(let codePoint):
				buffer.append(codePoint)
			}
		}
	}
	var	utf8	=	UTF8()
}
private enum _ReadingResult {
	case EOF
	case Bytes([UInt8])
}

private func _readBytes(count: Int, fromFileHandle: NSFileHandle) -> _ReadingResult {
	let	d	=	fromFileHandle.readDataOfLength(count)
	if d.length == 0 {
		return	.EOF
	}

	var	buffer	=	[UInt8]()
	var	p	=	unsafeBitCast(d.bytes, UnsafePointer<UInt8>.self)

	buffer.reserveCapacity(d.length)
	for _ in 0..<d.length {
		buffer.append(p.memory)
		p++
	}
	return	.Bytes(buffer)
}











private let	_BUFFER_SIZE_IN_BYTES	=	1024



