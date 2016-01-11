//
//  NavigatorViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class NavigatorViewController: CommonViewController {

	deinit {
		installer.deinstallIfNeeded {
			Workspace.Event.Notification.deregister(self)
		}
	}

	// MARK: -
	weak var workspace: Workspace? {
		didSet {
			_fileNavigatorVC.fileNavigator	=	workspace?.fileNavigator
			_issueNavigatorVC.issueNavigator	=	workspace?.issueNavigator
//			_debuggingNavigatorUI.model	=	workspace?.debug
			render()
		}
	}

	// MARK: -
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		render()
	}
	override func becomeFirstResponder() -> Bool {
		guard let workspace = workspace else { return super.becomeFirstResponder() }
		renderModeSelection()
		switch workspace.selectedNavigationPane {
		case .File:	return view.window!.makeFirstResponder(_fileNavigatorVC)
		case .Issue:	return view.window!.makeFirstResponder(_issueNavigatorVC)
		case .Debug:	return view.window!.makeFirstResponder(_debuggingNavigatorUI)
		}
	}

	// MARK: -
	private let _fileTreeToolButton			=	_instantiateScopeButton("Files")
	private let _issueListToolButton		=	_instantiateScopeButton("Issues")
	private let _debuggingToolButton		=	_instantiateScopeButton("Debug")
	private let _modeSelector			=	ToolButtonStrip()
	private let _separatorLine			=	Line()

	private let _fileNavigatorVC			=	FileNavigatorViewController()
	private let _issueNavigatorVC			=	IssueNavigatorViewController()
	private let _debuggingNavigatorUI		=	CommonViewController()

	private var installer = ViewInstaller()

}
extension NavigatorViewController {
	private func _onTapProjectPaneButton() {
		guard let workspace = workspace else { return }
		workspace.selectedNavigationPane = .File
	}
	private func _onTapIssuePaneButton() {
		guard let workspace = workspace else { return }
		workspace.selectedNavigationPane = .Issue
	}
	private func _onTapDebugPaneButton() {
		guard let workspace = workspace else { return }
		workspace.selectedNavigationPane = .Debug
	}
	private func process(n: Workspace.Event.Notification) {
		assert(workspace != nil)
		guard n.sender ==== workspace else {
			return
		}
		switch n.event {
		case .DidChangeLocation:
			render()
		case .DidChangeNavigationPaneSelection:
			renderModeSelection()
		}
	}

	private func render() {
		assert(workspace != nil)
		checkAndReportFailureToDevelopers(workspace != nil)
		guard let _ = workspace else { return }
		installer.installIfNeeded {
			_separatorLine.position = .MinY
			_separatorLine.lineColor = EditorWindowDivisionSplitDividerColor
			view.addSubview(_separatorLine)

			_modeSelector.interButtonGap = 2
			_modeSelector.toolButtons = [
				_fileTreeToolButton,
				_issueListToolButton,
				_debuggingToolButton,
			]
			view.addSubview(_modeSelector)

			addChildViewController(_fileNavigatorVC)
			view.addSubview(_fileNavigatorVC.view)

			addChildViewController(_issueNavigatorVC)
			view.addSubview(_issueNavigatorVC.view)

			addChildViewController(_debuggingNavigatorUI)
			view.addSubview(_debuggingNavigatorUI.view)

			_fileTreeToolButton.onClick	= { [weak self] in self?._onTapProjectPaneButton() }
			_issueListToolButton.onClick	= { [weak self] in self?._onTapIssuePaneButton() }
			_debuggingToolButton.onClick	= { [weak self] in self?._onTapDebugPaneButton() }

			Workspace.Event.Notification.register(self, self.dynamicType.process)
		}

		let box = view.bounds.toBox().toSilentBox()
		let (paneBox, selectorBox) = box.splitAtY(box.max.y - 30)
		_modeSelector.frame = selectorBox.toCGRect()
		_separatorLine.frame = selectorBox.toCGRect()
		_fileNavigatorVC.view.frame = paneBox.toCGRect()
		_issueNavigatorVC.view.frame = paneBox.toCGRect()
		_debuggingNavigatorUI.view.frame = paneBox.toCGRect()
		renderModeSelection()
	}
	private func renderModeSelection() {
		assert(workspace != nil)
		guard let workspace = workspace else { return }
		func setVisibility(visibleButton: ScopeButton, visibleViewController: NSViewController) {
			_fileTreeToolButton.selected		= visibleButton === _fileTreeToolButton
			_issueListToolButton.selected		= visibleButton === _issueListToolButton
			_debuggingToolButton.selected		= visibleButton === _debuggingToolButton
			_fileNavigatorVC.view.hidden			= visibleViewController !== _fileNavigatorVC
			_issueNavigatorVC.view.hidden		= visibleViewController !== _issueNavigatorVC
			_debuggingNavigatorUI.view.hidden	= visibleViewController !== _debuggingNavigatorUI
		}

		switch workspace.selectedNavigationPane {
		case .File:
			setVisibility(_fileTreeToolButton, visibleViewController: _fileNavigatorVC)
		case .Issue:
			setVisibility(_issueListToolButton, visibleViewController: _issueNavigatorVC)
		case .Debug:
			setVisibility(_debuggingToolButton, visibleViewController: _debuggingNavigatorUI)
		}
	}
}












////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
private func _instantiateScopeButton(title: String) -> ScopeButton {
	let	v	=	ScopeButton()
	v.onShouldChangeSelectionStateByUserClick	=	{ [weak v] in
		guard let v = v else {
			return	false
		}
		return	v.selected == false
	}
	v.title		=	title
	v.titleFont	=	NSFont.systemFontOfSize(NSFont.systemFontSizeForControlSize(.SmallControlSize))
	v.sizeToFit()
	return	v
}
//private func _instantiateScopeButton(title: String) -> NSButton {
//	let	sz	=	NSControlSize.SmallControlSize
//	let	v	=	NSButton()
//	v.font		=	NSFont.systemFontOfSize(NSFont.systemFontSizeForControlSize(sz))
//	v.controlSize	=	sz
//	v.title		=	title
//	v.bezelStyle	=	NSBezelStyle.RecessedBezelStyle
//	v.state		=	NSOffState
//	v.highlighted	=	false
//	v.showsBorderOnlyWhileMouseInside	=	true
//	v.setButtonType(NSButtonType.PushOnPushOffButton)
//	v.sizeToFit()
//	v.wantsLayer	=	true
//	return	v
//}

