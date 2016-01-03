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
			_fileTreeUI.fileNavigator = workspace?.fileNavigator
//			_issueListUI.model		=	workspace?.report
//			_debuggingNavigatorUI.model	=	workspace?.debug
			render()
		}
	}

	// MARK: -
	private let _fileTreeToolButton		=	_instantiateScopeButton("Files")
	private let _issueListToolButton	=	_instantiateScopeButton("Issues")
	private let _debuggingToolButton	=	_instantiateScopeButton("Debug")
	private let _modeSelector		=	ToolButtonStrip()
	private let _bottomLine			=	Line()

	private let _fileTreeUI			=	FileNavigatorViewController()
	private let _issueListUI		=	CommonViewController()
	private let _debuggingNavigatorUI	=	CommonViewController()

	private var installer = ViewInstaller()

}
extension NavigatorViewController {
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		render()
	}
	override func becomeFirstResponder() -> Bool {
		guard let workspace = workspace else { return super.becomeFirstResponder() }
		renderModeSelection()
		switch workspace.selectedNavigationPane {
		case .File:
			return view.window!.makeFirstResponder(_fileTreeUI)
		case .Issue:
			return view.window!.makeFirstResponder(_issueListUI)
		case .Debug:
			return view.window!.makeFirstResponder(_debuggingNavigatorUI)
		}
	}
}
private extension NavigatorViewController {
	func _onTapProjectPaneButton() {
		guard let workspace = workspace else { return }
		workspace.selectedNavigationPane = .File
	}
	func _onTapIssuePaneButton() {
		guard let workspace = workspace else { return }
		workspace.selectedNavigationPane = .Issue
	}
	func _onTapDebugPaneButton() {
		guard let workspace = workspace else { return }
		workspace.selectedNavigationPane = .Debug
	}
	func process(n: Workspace.Event.Notification) {
		assert(workspace != nil)
		guard n.sender === workspace else {
			return
		}
		switch n.event {
		case .DidChangeLocation:
			render()
		case .DidChangeNavigationPaneSelection:
			renderModeSelection()
		}
	}

	func render() {
		assert(workspace != nil)
		checkAndReportFailureToDevelopers(workspace != nil)
		guard let _ = workspace else { return }
		installer.installIfNeeded {
			_bottomLine.position = .MinY
			_bottomLine.lineColor = EditorWindowDivisionSplitDividerColor
			view.addSubview(_bottomLine)

			_modeSelector.interButtonGap = 2
			_modeSelector.toolButtons = [
				_fileTreeToolButton,
				_issueListToolButton,
				_debuggingToolButton,
			]
			view.addSubview(_modeSelector)

			addChildViewController(_fileTreeUI)
			view.addSubview(_fileTreeUI.view)

			addChildViewController(_issueListUI)
			view.addSubview(_issueListUI.view)

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
		_bottomLine.frame = selectorBox.toCGRect()
		_fileTreeUI.view.frame = paneBox.toCGRect()
		_debuggingNavigatorUI.view.frame = paneBox.toCGRect()
		renderModeSelection()
	}
	func renderModeSelection() {
		assert(workspace != nil)
		guard let workspace = workspace else { return }
		func setVisibility(visibleButton: ScopeButton, visibleViewController: NSViewController) {
			_fileTreeToolButton.selected		= visibleButton === _fileTreeToolButton
			_issueListToolButton.selected		= visibleButton === _issueListToolButton
			_debuggingToolButton.selected		= visibleButton === _debuggingToolButton
			_fileTreeUI.view.hidden			= visibleViewController !== _fileTreeUI
			_issueListUI.view.hidden		= visibleViewController !== _issueListUI
			_debuggingNavigatorUI.view.hidden	= visibleViewController !== _debuggingNavigatorUI
		}

		switch workspace.selectedNavigationPane {
		case .File:
			setVisibility(_fileTreeToolButton, visibleViewController: _fileTreeUI)
		case .Issue:
			setVisibility(_issueListToolButton, visibleViewController: _issueListUI)
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

