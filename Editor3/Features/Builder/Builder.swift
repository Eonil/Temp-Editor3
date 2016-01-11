//
//  Builder.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class Builder: OwnerBuilder {
	
	weak var ownerWorkspace: OwnerWorkspace?
	
        private(set) var state: State = .Ready {
		didSet {
			print(state)
                        Event.Notification(sender: self, event: .DidChangeState).broadcast()
                }
        }
	private(set) var issues: [BuildIssue] = []
	private(set) var log: String = "" {
		didSet {
		}
	}

	private var cargo: CargoTool?
}
extension Builder {
	enum Event {
		typealias Notification = EventNotification<Builder,Event>
		case DidChangeState
		case DidAddIssueAtIndex(Int)
		case DidRemoveAllIssues
	}

	enum State {
		/// Empty initial state.
		case Ready
		/// Processing...
		case Running
		/// Processing done. Resulted issues are remains.
		/// Cancellation also jumps to here.
		case Done
	}
}
extension Builder {
	/// Build program using Cargo.
	/// Can be executed only when;
	/// - `state == .Ready`
	/// - Owner workspace has a proper file URL.
	func runBuilding() {
		resetIfDone()
		removeAllIssues()
		assert(state == .Ready)
		assert(cargo == nil)
		assert(ownerWorkspace != nil)
		assert(ownerWorkspace!.locationURL != nil)
		assert(ownerWorkspace!.locationURL!.path != nil)
		guard let ownerWorkspace = ownerWorkspace else { return }
		guard let locationURL = ownerWorkspace.locationURL else { return }

		state = .Running
		cargo = CargoTool()
		guard let cargo = cargo else { return }
		do {
			cargo.onEvent = { [weak self] in self?.process($0) }
			try cargo.runBuildCommand(locationURL)
		}
		catch let error {
			appendIssue(.CannotRunCargoDueToError(error))
		}
	}
	func runCleaning() {
		resetIfDone()
		assert(state == .Ready)
		assert(cargo == nil)
		assert(ownerWorkspace != nil)
		assert(ownerWorkspace!.locationURL != nil)
		assert(ownerWorkspace!.locationURL!.path != nil)
		guard let ownerWorkspace = ownerWorkspace else { return }
		guard let locationURL = ownerWorkspace.locationURL else { return }

		state = .Running
		cargo = CargoTool()
		guard let cargo = cargo else { return }
		do {
			try cargo.runCleanCommand(locationURL)
		}
		catch let error {
			appendIssue(.CannotRunCargoDueToError(error))
		}

	}
	/// This stops any running command synchronously.
	/// `state` becomes `.Done`.
	func cancelRunningAnyway() {
		cargo?.cancelRunningAnyway()
		cargo = nil
	}
}
extension Builder {
	private func removeAllIssues() {
		issues.removeAll()
		Event.Notification(sender: self, event: .DidRemoveAllIssues).broadcast()
	}
	private func appendIssue(issue: BuildIssue) {
		let idx = issues.count
		issues.append(issue)
		Event.Notification(sender: self, event: .DidAddIssueAtIndex(idx)).broadcast()
	}
	private func resetIfDone() {
		cancelRunningAnyway()
		guard state == .Done else { return }
		state = .Ready
	}
	private func process(e: CargoTool.Event) {
		switch e {
		case .DidStart:
			break
			
		case .DidGenerateMessage(let message):
			log.appendContentsOf(message)

		case .DidGenerateIssue(let issue):
			appendIssue(BuildIssue.CargoIssue(issue))

		case .DidEnd:
			assert(state == .Running)
			state = .Done
		}
	}
}
























