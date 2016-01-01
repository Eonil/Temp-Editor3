//
//  CargoShellExecutor.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class CargoShellExecutor {
	var onEvent: (Event->())?
	private let transition		=	Transition(.Ready, CargoTool3.defaultTransitionRules())
	private let shell		=	ShellTaskExecutionController()
	private var stdoutUTF8Decoder	=	_UTF8Decoder()
	private var stderrUTF8Decoder	=	_UTF8Decoder()
	private var isShellLaunched	=	AtomicBool(false)
	private var isShellTerminated	=	AtomicBool(false)
	private var stdoutEOF		=	AtomicBool(false)
	private var stderrEOF		=	AtomicBool(false)
	private let waitSema		=	dispatch_semaphore_create(0)!
	private var shouldBeStateDone	=	AtomicBool(false)

	init() {
	}
	deinit {
		cleanup()
	}
}
extension CargoShellExecutor {
	enum Event {
		/// It's guaranteed that this won't be called anymore since `onTermination` has been called.
		case StandardOutput(String)
		/// It's guaranteed that this won't be called anymore since `onTermination` has been called.
		case StandardError(String)
		case Done
	}
}
extension CargoShellExecutor {
	func launch(workingDirectoryPath: String) {
		assertMainThread()
		precondition(transition.state == .Ready)
		transition.state =  .Running
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
		if shouldBeStateDone.state {
			if transition.state == .Running {
				transition.state = .Cleaning
				transition.state = .Done
				assert(onEvent != nil)
				onEvent?(.Done)
			}
		}
	}
	func execute(command: String) {
		assertMainThread()
		precondition(transition.state == .Running, "You can execute only on a running executor.")
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
private extension CargoShellExecutor {
	func fireEvent(event: Event) {
		assert(onEvent != nil)
		onEvent?(event)
	}
	func runReadingStandardOutputOnNonMainThread() {
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
	func runReadingStandardErrorOnNonMainThread() {
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
	func onShellTerminationOnNonMainThread() {
		assertNonMainThread()
		dispatchToNonMainQueueAsynchronously { [weak self] in
			// We cannot roun-trip to main thread because it can be blocked by `wait` at this point.
			// So, we made all flags atomic.
			self!.isShellTerminated.state = true
			if self!.stdoutEOF.state && self!.stderrEOF.state {
				self!.shouldBeStateDone.state = true //< We need this because main thread can be blocked by `wait` call.
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
	func cleanup() {
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



