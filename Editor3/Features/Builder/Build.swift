//
//  Build.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class Builder {
	weak var ownerWorkspace: OwnerWorkspace?
	
        private(set) var state: State = .Ready {
                didSet {
                        Event.Notification(sender: self, event: .DidChangeState).broadcast()
                }
        }

	private(set) var issues: [BuildIssue] = [] {
		didSet {
			Event.Notification(sender: self, event: .DidChangeIssues).broadcast()
		}
	}

	private var cargo: CargoTool?
}
extension Builder {
	enum Event {
		typealias Notification = EventNotification<Builder,Event>
		case DidChangeState
		case DidChangeIssues
	}

	enum State {
		case Ready
		case Running
		case Done
	}
}
extension Builder {
	/// Can be executed only when;
	/// - `state == .Ready`
	/// - Owner workspace has a proper file URL.
	func runBuilding() {
		resetIfDone()
		assert(state == .Ready)
		assert(ownerWorkspace != nil)
		assert(ownerWorkspace!.locationURL != nil)
		assert(ownerWorkspace!.locationURL!.path != nil)
		guard let ownerWorkspace = ownerWorkspace else { return }
		guard let locationURL = ownerWorkspace.locationURL else { return }
		guard let path = locationURL.path else { return }
		cargo = CargoTool()
		guard let cargo = cargo else { return }
		cargo.runBuild(path: path)
	}
	func runCleaning() {
		resetIfDone()
		assert(state == .Ready)
		assert(ownerWorkspace != nil)
		assert(ownerWorkspace!.locationURL != nil)
		assert(ownerWorkspace!.locationURL!.path != nil)
		guard let ownerWorkspace = ownerWorkspace else { return }
		guard let locationURL = ownerWorkspace.locationURL else { return }
		guard let path = locationURL.path else { return }
		cargo = CargoTool()
		guard let cargo = cargo else { return }
		cargo.runClean(path: path)
	}
}
private extension Builder {
	private func resetIfDone() {
		guard state == .Done else { return }
		state = .Ready
		cargo?.cancelRunning()
		cargo = nil
	}
}
























