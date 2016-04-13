//
//  Workspace.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// A `Workspace` is not bound to a specific URL.
/// URL of a workspace can be changed to something else at anytime.
/// A Workspace must be handled using object identity.
final class Workspace: OwnerWorkspace {
	enum Event {
		typealias Notification = EventNotification<Workspace,Event>
		case DidChangeLocation
		case DidChangeNavigationPaneSelection
//		case RecoverableError(ErrorType)
	}
	enum State {
		case Normal
		case Error(Workspace.Error)
	}
	enum Error: ErrorType {
		case CannotReadWorkspaceFileList
		case CannotWriteWorkspaceFileList
	}

	// MARK: -

	weak var ownerEditor: OwnerEditor?
	let textEditor = TextEditor()
	let fileNavigator = FileNavigator()
	let issueNavigator = IssueNavigator()
	let builder = Builder()
	let debugger = Debugger()

	enum NavigationPaneCode {
		case File
		case Issue
		case Debug
	}
	var selectedNavigationPane: NavigationPaneCode = .File {
		didSet {
			Event.Notification(sender: self, event: .DidChangeNavigationPaneSelection).broadcast()
		}
	}

	/// Setting this property will trigger reloading of whole workspace.
	/// Reloading of a workspace always completes with no error throwing.
	/// Anyway, workspace will be set to "error mode" if any error occured
	/// in loading process.
	var locationURL: NSURL? {
		willSet {
			assert(newValue == nil || ((try? newValue!.isExistingAsDirectoryFile()) ?? false))
			//assert(newValue.isdi)
		}
		didSet {
			guard locationURL != oldValue else { return }
			fileNavigator.reloadFileList()
			Event.Notification(sender: self, event: .DidChangeLocation).broadcast()
		}
	}

	init() {
                textEditor.ownerWorkspace = self
                fileNavigator.ownerWorkspace = self
		issueNavigator.ownerWorkspace = self
		builder.ownerWorkspace = self
                FileNavigator.Event.Notification.register(self, self.dynamicType.process)
        }
        deinit {
                FileNavigator.Event.Notification.deregister(self)
        }

}
extension Workspace {
//	func reloadFileTree() {
////		assert(ownerDocument != nil)
////		guard let ownerDocument = ownerDocument else { return }
////		locationURL = ownerDocument.fileURL
//
//		// Test.
//		locationURL = NSURL(string: "file:///Users/Eonil/Temp/a2")
//	}
}
private extension Workspace {
        func process(n: FileNavigator.Event.Notification) {
                guard n.sender.ownerWorkspace is Workspace && n.sender.ownerWorkspace === self else { return }
                switch n.event {
                case .DidChangeTree:
                        break
                case .DidChangeSelection:
			guard let firstSelection = n.sender.selection.first else { return }
			let maybeURL = firstSelection.resolvePath().absoluteFileURLForWorkspace(self)
			checkAndReportFailureToDevelopers(maybeURL != nil)
			guard let url = maybeURL else { return }
			textEditor.editingFileURL = nil
			if firstSelection.isGroup == false {
				textEditor.editingFileURL = url
			}
		case .DidChangeIssues:
			break
                }
        }
}

























