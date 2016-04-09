//
//  FileNavigatorViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

extension FileNavigatorViewController {
	enum Error: ErrorType {
		case CannotGetPathFromFileNodePathURL
	}
}
final class FileNavigatorViewController: CommonViewController {

	override init() {
		super.init()
		FileNavigator.Event.Notification.register(self, self.dynamicType.process)
		FileNode.Event.Notification.register(self, self.dynamicType.process)
	}
	deinit {
		FileNode.Event.Notification.deregister(self)
		FileNavigator.Event.Notification.deregister(self)
	}

	weak var fileNavigator: FileNavigator? {
		didSet {
			render()
		}
	}

	// MARK: -
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		render()
	}

	// MARK: -
	private let scrollView = CommonViewFactory.instantiateScrollViewForNavigators()
	private let outlineView = CommonViewFactory.instantiateOutlineViewForUseInSidebar()
	private var installer = ViewInstaller()
	private func process(n: FileNavigator.Event.Notification) {
		guard n.sender ==== fileNavigator else { return }
		switch n.event {
		case .DidChangeIssues:
			render()
		case .DidChangeSelection:
			break
		case .DidChangeTree:
			render()
		}
	}
	private func process(n: FileNode.Event.Notification) {
		guard n.sender.ownerFileNavigator === fileNavigator else { return }
		switch n.event {
		case .DidChange:
			render()
		}
	}
	private func processOutlineSelectionDidChange() {
		guard let fileNavigator = fileNavigator else { return }
		var nodes = [FileNode]()
		for idx in outlineView.selectedRowIndexes {
			checkAndReportFailureToDevelopers(idx != NSNotFound)
			checkAndReportFailureToDevelopers(outlineView.itemAtRow(idx) is FileNode)
			guard idx != NSNotFound else { continue }
			guard let node = outlineView.itemAtRow(idx) as? FileNode else { continue }
			nodes.append(node)
		}
		fileNavigator.selection = nodes

//		guard let fileNavigator = fileNavigator else { return }
//		guard outlineView.selectedRow != NSNotFound else { return }
//		guard let selectedFileNode = outlineView.itemAtRow(outlineView.selectedRow) as? FileNode else { return }
//		fileNavigator.selection = [selectedFileNode]
	}
	private func render() {
		installer.installIfNeeded {
			view.addSubview(scrollView)
			scrollView.documentView = outlineView
			outlineView.setDataSource(self)
			outlineView.setDelegate(self)
		}
		scrollView.frame = view.bounds
//		let newOutlineViewEnabledSTate = fileNavigator != nil
//		if outlineView.enabled != newOutlineViewEnabledSTate {
////
//		}
		outlineView.enabled = fileNavigator != nil
		outlineView.reloadData()
	}
}

// MARK: -
extension FileNavigatorViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
	@objc
	func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
		guard let fileNavigator = fileNavigator else { return 0 }
		guard let fileNode = item as? FileNode else { return fileNavigator.tree == nil ? 0 : 1 }
		return fileNode.subnodes.count
	}
	@objc
	func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
		assert(fileNavigator != nil)
		assert(item is FileNode)
		guard let fileNode = item as? FileNode else { return false }
		return fileNode.isGroup
	}
	@objc
	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		assert(fileNavigator != nil)
		assert(fileNavigator!.tree != nil)
		assert(item == nil || item is FileNode)
		guard let fileNavigator = fileNavigator else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		guard let tree = fileNavigator.tree else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		guard let fileNode = item as? FileNode else { return tree }
		return fileNode.subnodes[index]
	}
	@objc
	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		assert(fileNavigator != nil)
		assert(fileNavigator!.tree != nil)
		assert(fileNavigator!.ownerWorkspace != nil)
		assert(item is FileNode)
		guard let fileNavigator = fileNavigator else { return nil }
		guard let ownerWorkspace = fileNavigator.ownerWorkspace else { return nil }
		guard let fileNode = item as? FileNode else { return nil }

		let label = fileNode.resolvePath().lastPart ?? ownerWorkspace.locationURL?.lastPathComponent ?? "(????)"
		let cellView = FileNavigatorCellView()
		cellView.fileNode = fileNode
		cellView.state = (NSImage(), label)
//		cellView.textFieldDelegate =
		return cellView
	}

	@objc
	func outlineView(outlineView: NSOutlineView, shouldTrackCell cell: NSCell, forTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> Bool {
		return true
	}
	@objc
	func outlineViewSelectionDidChange(notification: NSNotification) {
		processOutlineSelectionDidChange()
	}
	@objc
	func outlineView(outlineView: NSOutlineView, writeItems items: [AnyObject], toPasteboard pasteboard: NSPasteboard) -> Bool {
		assert(fileNavigator != nil)
		assert(fileNavigator!.tree != nil)
		assert(fileNavigator!.ownerWorkspace != nil)
		assert(items is [FileNode])
		guard let fileNavigator = fileNavigator else { return false }
		guard let ownerWorkspace = fileNavigator.ownerWorkspace else { return false }
		guard let fileNodes = items as? [FileNode] else { return false }

		ownerWorkspace.locationURL
		enum PathResolutionError: ErrorType {
			case CannotResolveAbsoluteFileURL
			case CannotResolveFilePathOfURL
		}
		func toPath(fileNode: FileNode) throws -> String {
			guard let fileURL = fileNode.resolvePath().absoluteFileURLForWorkspace(ownerWorkspace) else { throw PathResolutionError.CannotResolveAbsoluteFileURL }
			guard let filePath = fileURL.path else { throw PathResolutionError.CannotResolveFilePathOfURL }
			return filePath
		}
		do {
			let filePaths = try fileNodes.map(toPath)
			pasteboard.declareTypes([NSFilenamesPboardType], owner: self)
			pasteboard.setPropertyList(filePaths, forType: NSFilenamesPboardType)
			return	true
		}
		catch let error {
			reportToDevelopers(error)
			return false
		}
	}

	@objc
	func outlineView(outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: AnyObject?, proposedChildIndex index: Int) -> NSDragOperation {
		return	[.Copy]
	}
	@objc
	func outlineView(outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: AnyObject?, childIndex index: Int) -> Bool {
		assert(fileNavigator != nil)
		assert(fileNavigator!.tree != nil)
		assert(fileNavigator!.ownerWorkspace != nil)
		assert(item is FileNode)
		guard let fileNavigator = fileNavigator else { return false }
		guard let ownerWorkspace = fileNavigator.ownerWorkspace else { return false }
		guard let fileNode = item as? FileNode else { return false }
		guard fileNode.isGroup == true else { return false } // You cannot drop onto a non-group node.

		let pasteboard = info.draggingPasteboard()
		let files = pasteboard.propertyListForType(NSFilenamesPboardType)
		guard let filePaths = files as? NSArray as? [String] else { return false } // Non-string paths are unsupported.

//		var subnodes	=	[FileNodeModel]()
//		for fileURL in fileURLs {
//			guard let filePath = fileURL.path else {
//				break
//			}
//			guard let fileName = fileURL.lastPathComponent else {
//				break
//			}
//			var	isDir	=	false as ObjCBool
//			let	ok	=	NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory: &isDir)
//			guard ok else {
//				break
//			}
//			let	n	=	FileNodeModel(name: fileName, isGroup: false)
//			subnodes.append(n)
//		}
//
////		// Transactional commit.
////		for i in 0..<subnodes.count {
////			try? item.subnodes.insert(subnodes[i], at: index + i)
////		}
		return	false
	}
}


















