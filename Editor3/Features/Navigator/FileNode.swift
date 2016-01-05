//
//  FileNode.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

final class FileNode {
	private(set) weak var ownerFileNavigator: OwnerfileNavigator?
	private(set) weak var supernode: FileNode?

	private(set) var name: String {
		didSet {
			guard name != oldValue else { return }
			Event.Notification(sender: self, event: .DidChange).broadcast()
		}
	}
	private(set) var comment: String? {
		didSet {
			guard comment != oldValue else { return }
			Event.Notification(sender: self, event: .DidChange).broadcast()
		}
	}
	private(set) var isGroup: Bool = false {
		didSet {
			guard isGroup != oldValue else { return }
			Event.Notification(sender: self, event: .DidChange).broadcast()
		}
	}
	private(set) var subnodes: [FileNode] = [] {
		didSet {
			Event.Notification(sender: self, event: .DidChange).broadcast()
		}
	}

	init(name: String, isGroup: Bool = false) {
		self.name = name
		self.isGroup = isGroup
	}
}
extension FileNode {
	enum Event {
		typealias Notification = EventNotification<FileNode,Event>
		case DidChange
	}
	enum Error: ErrorType {
		case SnapshotRootItemIsNotGroup
		case SnapshotSubitemWithBadPath(WorkspaceItemPath)
		case SnapshotSubitemWithNoOwner(WorkspaceItemPath)
		case SnapshotSubitemWithNoName(WorkspaceItemPath)
	}
}
// MARK: - WorkspacePath Utilities
extension FileNode {
	/// O(n).
	func rootNode() -> FileNode {
		if let supernode = supernode {
			return supernode.rootNode()
		}
		return self
	}
	func appendSubnode(subnode: FileNode) {
		preconditionAndReportFailureToDevelopers(subnode.supernode === nil)
		subnode.supernode = self
		subnodes.append(subnode)
	}
	func removeSubnode(subnode: FileNode) {
		subnodes = subnodes.filter({ $0 !== subnode })
	}
	func resolvePath() -> WorkspaceItemPath {
		if let supernode = supernode {
			return supernode.resolvePath().pathByAppendingLastComponent(name)
		}
		else {
			return WorkspaceItemPath.root
		}
	}
	func searchSubnodeWithPath(path: WorkspaceItemPath) -> FileNode? {
		guard rootNode() === self else { return rootNode().searchSubnodeWithPath(path) }
		return searchSubnodeWithSubpath(path)
	}
}
// MARK: - Snapshot with WorkspaceItemPath
extension FileNode {
	/// Strict snapshot deserializer. No error tolerance.
	convenience init(snapshot: String) throws {
		self.init(name: "Workspace")
		let list = try WorkspaceItemSerialization.deserializeList(snapshot)
		for item in list {
			func reconfigureNode(node: FileNode) {
				node.comment = item.comment
				node.isGroup = item.group
			}
			if item.path == WorkspaceItemPath.root {
				// Root means this object itself.
				// No need to create.
				guard item.group else { throw Error.SnapshotRootItemIsNotGroup }
				self.comment = item.comment
				self.isGroup = item.group
			}
			else {
				assert(item.path.parts.count > 0)
				guard item.path.parts.count >= 1 else { throw Error.SnapshotSubitemWithBadPath(item.path) }
				let parentPath = item.path.lastPartDeleted()
				guard let parent = searchSubnodeWithPath(parentPath) else { throw Error.SnapshotSubitemWithNoOwner(item.path) }
				guard let name = item.path.lastPart else { throw Error.SnapshotSubitemWithNoName(item.path) }
				let child = FileNode(name: name)
				parent.appendSubnode(child)
				child.comment = item.comment
				child.isGroup = item.group
			}
		}
	}
	/// Current node must a a root node.
	func snapshot() -> String {
		assert(supernode == nil)
		preconditionAndReportFailureToDevelopers(supernode == nil)
		var items = Array<WorkspaceItemSerialization.PersistentItem>()
		walk { node in
			let item = node.toPersistentItem()
			items.append(item)
		}
		return WorkspaceItemSerialization.serializeList(items)
	}
}
// MARK: -
private extension FileNode {
	func searchSubnodeWithSubpath(subpath: WorkspaceItemPath) -> FileNode? {
		guard subpath.parts.count > 0 else { return self }
		guard let firstPart = subpath.parts.first else { return self }
		for node in subnodes.reverse() {
			if node.name == firstPart {
				return node.searchSubnodeWithPath(subpath.firstPartDeleted())
			}
		}
		return nil
	}
	/// Walk from here.
	func walk(@noescape f: FileNode->()) {
		f(self)
		for subnode in subnodes {
			subnode.walk(f)
		}
	}
	func toPersistentItem() -> WorkspaceItemSerialization.PersistentItem {
		return (resolvePath(), isGroup, comment)
	}
}



























