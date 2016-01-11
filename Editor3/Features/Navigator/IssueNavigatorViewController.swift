//
//  IssueNavigatorViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/07.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class IssueNavigatorViewController: CommonViewController {

	deinit {
		IssueNavigator.Event.Notification.deregister(self)
	}

	weak var issueNavigator: IssueNavigator? {
		didSet {
			render()
		}
	}

	override func installSubcomponents() {
		super.installSubcomponents()
		installIfNeeded()
		render()
	}
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		installIfNeeded()
		render()
	}

	// MARK: -
	private let scrollView = CommonViewFactory.instantiateScrollViewForNavigators()
	private let outlineView = CommonViewFactory.instantiateOutlineViewForUseInSidebar()
	private var installer = ViewInstaller()
	private func installIfNeeded() {
		installer.installIfNeeded {
			outlineView.setDataSource(self)
			outlineView.setDelegate(self)
			scrollView.documentView = outlineView
			view.addSubview(scrollView)
			IssueNavigator.Event.Notification.register(self, self.dynamicType.process)
		}
		scrollView.frame = view.bounds
	}
	private func process(n: IssueNavigator.Event.Notification) {
		guard n.sender ==== issueNavigator else { return }
		render()
	}
	private func processOutlineSelectionDidChange() {

	}
	private func render() {
		outlineView.reloadData()
	}
}

// MARK: -
extension IssueNavigatorViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
	@objc
	@available(*,unavailable)
	func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
		guard let issueNavigator = issueNavigator else { return 0 }
		if item !== nil { return 0 }
		return issueNavigator.issueNodes.count
	}
	@objc
	@available(*,unavailable)
	func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
		return false
	}
	@objc
	@available(*,unavailable)
	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		assert(issueNavigator != nil)
		guard let issueNavigator = issueNavigator else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		return issueNavigator.issueNodes[index]
	}
	@objc
	@available(*,unavailable)
	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		assert(issueNavigator != nil)
		assert(item is IssueNode)
		guard let issueNode = item as? IssueNode else { return nil }
		let cellView = IssueNavigatorCellView()
		cellView.issue = issueNode.issue
		return cellView
	}

	@objc
	@available(*,unavailable)
	func outlineView(outlineView: NSOutlineView, shouldTrackCell cell: NSCell, forTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> Bool {
		return true
	}
	@objc
	@available(*,unavailable)
	func outlineViewSelectionDidChange(notification: NSNotification) {
		processOutlineSelectionDidChange()
	}
//	@objc
//	@available(*,unavailable)
//	func outlineView(outlineView: NSOutlineView, writeItems items: [AnyObject], toPasteboard pasteboard: NSPasteboard) -> Bool {
//		assert(issueNavigator != nil)
//		assert(issueNavigator!.tree != nil)
//		assert(issueNavigator!.ownerWorkspace != nil)
//		assert(items is [FileNode])
//		guard let issueNavigator = issueNavigator else { return false }
//		guard let ownerWorkspace = issueNavigator.ownerWorkspace else { return false }
//		guard let fileNodes = items as? [FileNode] else { return false }
//
//		ownerWorkspace.locationURL
//		enum PathResolutionError: ErrorType {
//			case CannotResolveAbsoluteFileURL
//			case CannotResolveFilePathOfURL
//		}
//		func toPath(fileNode: FileNode) throws -> String {
//			guard let fileURL = fileNode.resolvePath().absoluteFileURLForWorkspace(ownerWorkspace) else { throw PathResolutionError.CannotResolveAbsoluteFileURL }
//			guard let filePath = fileURL.path else { throw PathResolutionError.CannotResolveFilePathOfURL }
//			return filePath
//		}
//		do {
//			let filePaths = try fileNodes.map(toPath)
//			pasteboard.declareTypes([NSFilenamesPboardType], owner: self)
//			pasteboard.setPropertyList(filePaths, forType: NSFilenamesPboardType)
//			return	true
//		}
//		catch let error {
//			reportToDevelopers(error)
//			return false
//		}
//	}
}

