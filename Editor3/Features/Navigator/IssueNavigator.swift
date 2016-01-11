//
//  IssueNavigator.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/07.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class IssueNavigator {
	enum Event {
		typealias Notification = EventNotification<IssueNavigator,Event>
		case DidAppendIssueAtIndex(Int)
		case DidRemoveAllIssues
	}

	init() {
		Builder.Event.Notification.register(self, self.dynamicType.process)

	}
	deinit {
		Builder.Event.Notification.deregister(self)
	}

	// MARK: -
	weak var ownerWorkspace: OwnerWorkspace?
	
	/// Ad hoc. Not very well designed.
	private(set) var issueNodes: [IssueNode] = []

	func clearAllIssues() {
		issueNodes.removeAll()
		Event.Notification(sender: self, event: .DidRemoveAllIssues).broadcast()
	}
	func appendIssue(issue: Issue) {
		let idx = issueNodes.count
		issueNodes.append(IssueNode(issue: issue))
		Event.Notification(sender: self, event: .DidAppendIssueAtIndex(idx)).broadcast()
	}

	// MARK: -
	private func process(n: Builder.Event.Notification) {
		assert(ownerWorkspace != nil)
		guard let ownerWorkspace = ownerWorkspace else { return }
		guard n.sender.ownerWorkspace === ownerWorkspace else { return }
		switch n.event {
		case .DidChangeState:
			break
		case .DidRemoveAllIssues:
			clearAllIssues()
		case .DidAddIssueAtIndex(let index):
			appendIssue(Issue.BuildIssue(n.sender.issues[index]))
		}
	}
}

final class IssueNode {
	var issue: Issue
	init(issue: Issue) {
		self.issue = issue
	}
}





