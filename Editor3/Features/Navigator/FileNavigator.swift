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
	private var issues = Issues()
//	private(set) var issues = [FileNavigatorIssue]() {
//		didSet {
//			Event.Notification(sender: self, event: .DidChangeIssues).broadcast()
//		}
//	}
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
	func persistFileList() { persistFileListImpl() }
	func canCreateNewFile() -> Bool { return canCreateNewFileImpl() }
	func canCreateNewFolder() -> Bool { return canCreateNewFolderImpl() }
	func canDelete() -> Bool { return canDeleteImpl() }
	func createNewFile() { return createNewFileImpl() }
	func createNewFolder() { return createNewFolderImpl() }
	func delete() { return deleteImpl() }
}
extension FileNavigator {
	enum Event {
		typealias Notification = EventNotification<FileNavigator,Event>
		case DidChangeTree
		case DidChangeSelection
		case DidChangeIssues
	}
	struct Issues {
		var cannotReloadFileList: Bool	=	false
		var cannotPersistFileList: Bool	=	false
	}
}
private extension FileNavigator {
	/// Errors are private and hidden from users because these informations are 
	/// intended for debugging, and not to inform users.
	private enum Error: ErrorType {
		case MissingOwnerWorkspace
		case MissingOwnerWorkspaceLocationURL
		case MissingFileTree
		case SnapshotDecodingFailureFromUTF8
		case SnapshotEncodingFailureIntoUTF8
	}
	private func getWorkspaceFileListURL() throws -> NSURL {
		guard let ownerWorkspace = ownerWorkspace else { throw Error.MissingOwnerWorkspace }
		guard let locationURL = ownerWorkspace.locationURL else { throw Error.MissingOwnerWorkspaceLocationURL }
		let workspaceFileListURL = locationURL.URLByAppendingPathComponent("Workspace.EditorFileList")
		return workspaceFileListURL
	}
	private func reloadFileListImpl() {
		assert(ownerWorkspace != nil)
		checkAndReportFailureToDevelopers(ownerWorkspace != nil)
		do {
			tree = nil
			try {
				let workspaceFileListURL = try getWorkspaceFileListURL()
				let data = try NSData(contentsOfURL: workspaceFileListURL, options: [])
				guard let snapshot = NSString(data: data, encoding: NSUTF8StringEncoding) else { throw Error.SnapshotDecodingFailureFromUTF8 }
				tree = try FileNode(snapshot: snapshot as String)
			}()
			issues.cannotReloadFileList = false
		}
		catch let error {
			reportToDevelopers(error)
			issues.cannotReloadFileList = true
		}
	}
	private func persistFileListImpl() {
		assert(ownerWorkspace != nil)
		assert(tree != nil)
		checkAndReportFailureToDevelopers(ownerWorkspace != nil)
		checkAndReportFailureToDevelopers(tree != nil)
		do {
			try {
				let workspaceFileListURL = try getWorkspaceFileListURL()
				guard let tree = tree else { throw Error.MissingFileTree }
				let snapshot = tree.snapshot()
				guard let data = snapshot.dataUsingEncoding(NSUTF8StringEncoding) else { throw Error.SnapshotEncodingFailureIntoUTF8 }
				try data.writeToURL(workspaceFileListURL, options: [])
			}()
			issues.cannotPersistFileList = false
		}
		catch let error {
			reportToDevelopers(error)
			issues.cannotPersistFileList = true
		}
	}
	private func getFirstSelectedGroupNode() -> FileNode? {
		for node in selection {
			if node.isGroup { return node }
		}
		return nil
	}
	private func canCreateNewFileImpl() -> Bool {
		guard let _ = tree else { return false }
		guard selection.count == 1 else { return false }
		guard let parent = selection.first else { return false }
		guard parent.isGroup == true else { return false }
		guard let node = getFirstSelectedGroupNode() else { return false }
		assert(node.rootNode() === tree)
		guard node.rootNode() === tree else { return false }
		return true
	}
	private func canDeleteImpl() -> Bool {
		guard selection.contains({ $0 === tree }) == false else { return false }
		return selection.count > 0
	}
	private func createNewFileImpl() {
		// Catch errors and convert into issues.
		// Do not throw errors out.
		assert(canCreateNewFile())
		guard let parentNode = getFirstSelectedGroupNode() else { return reportToDevelopers() }
		let newSubnode = FileNode(name: "file0.rs")
		parentNode.appendSubnode(newSubnode)
		persistFileList()
	}
	private func canCreateNewFolderImpl() -> Bool {
		return canCreateNewFile()
	}
	private func createNewFolderImpl() {
		// Catch errors and convert into issues.
		// Do not throw errors out.
		assert(canCreateNewFolder())
		guard let parentNode = getFirstSelectedGroupNode() else { return reportToDevelopers() }
		let newSubnode = FileNode(name: "folder0.rs", isGroup: true)
		parentNode.appendSubnode(newSubnode)
		persistFileList()
	}
	private func deleteImpl() {
		assert(canDelete())
//		typealias Pair = (path: WorkspaceItemPath, node: FileNode)
//		func checkWhetherSubtree(a: FileNode, contains b: FileNode) -> Bool {
//			if a === b { return true }
//			guard let b1 = b.supernode else { return false }
//			return checkWhetherSubtree(a, contains: b1)
//		}
		for node in selection {
			guard node !== tree else { continue } 			//< Cannot remove root node.
			guard let supernode = node.supernode else { continue }
			guard node.rootNode() === tree else { continue }	//< Cannot remove detached node.
			supernode.removeSubnode(node)
		}
	}
}

















































