//
//  FileNavigator.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class FileNavigator: OwnerfileNavigator {
	weak var ownerWorkspace: OwnerWorkspace?
	private(set) var issues = [FileNavigatorIssue]() {
		didSet {
			Event.Notification(sender: self, event: .DidChangeIssues).broadcast()
		}
	}
        private(set) var tree: FileNode? {
                didSet {
                        guard tree !== oldValue else { return }
			selection.removeAll()
                        Event.Notification(sender: self, event: .DidChangeTree).broadcast()
                }
        }
	var selection: [FileNode] = [] {
		willSet {
			assert(newValue.map { $0.rootNode() === tree }.reduce(true) { $0 && $1 })
		}
                didSet {
                        func equalityOf(a: [FileNode], _ b: [FileNode]) -> Bool {
                                guard a.count == b.count else { return false }
                                for i in 0..<a.count {
                                        guard a[i] === b[i] else { return false }
                                }
				return true
                        }
                        guard equalityOf(selection, oldValue) == false else { return }
                        Event.Notification(sender: self, event: .DidChangeSelection).broadcast()
                }
	}
	/// Reloads workspace file list. Conceptually, this synchronises current state to workspce's location.
	/// Non-nil `ownerWorkspace` is required.
	/// This will post ro `issues` on any error.
	/// `tree` remains `nil` if loading failed.
	func reloadFileList() { reloadFileListImpl() }
}
extension FileNavigator {
	enum Event {
		typealias Notification = EventNotification<FileNavigator,Event>
		case DidChangeTree
		case DidChangeSelection
		case DidChangeIssues
	}
	struct ErrorState {

		var badOrMissingWorkspaceFileList: Bool = false
		var workspaceFileListParsingError: ErrorType?
	}
}
private extension FileNavigator {
	func reloadFileListImpl() {
		assert(ownerWorkspace != nil)
		checkAndReportFailureToDevelopers(ownerWorkspace != nil)
		guard let ownerWorkspace = ownerWorkspace else { return }

		tree = nil
		guard let workspaceFileListURL = ownerWorkspace.locationURL?.URLByAppendingPathComponent("Workspace.EditorFileList") else { return }
		guard let data = NSData(contentsOfURL: workspaceFileListURL) else {
			issues.append(FileNavigatorIssue.CannotReadWorkspaceFileListFileFromURL(location: workspaceFileListURL))
			return
		}
		guard let snapshot = NSString(data: data, encoding: NSUTF8StringEncoding) as String? else {
			issues.append(FileNavigatorIssue.CannotDecodeWorkspaceFileListFileAsUTF8(data: data))
			return
		}
		do {
			tree = try FileNode(snapshot: snapshot)
		}
		catch let error {
			issues.append(FileNavigatorIssue.CannotParseWorkspaceFileListFile(snapshot: snapshot, dueToError: error))
		}
	}
}

















































