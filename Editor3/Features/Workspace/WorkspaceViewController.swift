
//  WorkspaceViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class WorkspaceViewController: CommonViewController {

        weak var workspace: Workspace? {
                didSet {
			navigatorViewController.workspace = workspace
			fileNavigatorViewController.fileNavigator = workspace?.fileNavigator
                        render()
                }
        }

        // MARK: -
	override func layoutSubcomponents() {
		super.layoutSubcomponents()
		render()
	}

        // MARK: -
        private let outerSplitViewController = PaneSplitViewController()
        private let innerSplitViewController = PaneSplitViewController()
	private let navigatorViewController = NavigatorViewController()
        private let fileNavigatorViewController = FileNavigatorViewController()
        private let textEditorViewController = TextEditorViewController()
	private let inspectorViewController = CommonViewController()
	private let consoleViewController = CommonViewController()
        private var installer = ViewInstaller()
        private func render() {
                guard let workspace = workspace else { return }
		installer.installIfNeeded {
			assert(view.window!.appearance != nil)
			assert(view.window!.appearance!.name == NSAppearanceNameVibrantDark)
			view.wantsLayer							=	true
			outerSplitViewController.paneSplitView.dividerThickness		=	0
			outerSplitViewController.paneSplitView.dividerColor		=	NSColor.clearColor()
			innerSplitViewController.paneSplitView.dividerThickness		=	1
			innerSplitViewController.paneSplitView.dividerColor		=	EditorWindowDivisionSplitDividerColor
			innerSplitViewController.paneSplitView.backgroundColor		=	NSColor.blackColor()

			// Initial metrics defines initial layout. We need these.
			navigatorViewController.view.frame.size.width	=	200
			inspectorViewController.view.frame.size.width	=	200
			consoleViewController.view.frame.size.height	=	100

			func navItem() -> NSSplitViewItem {
				let m = NSSplitViewItem(sidebarWithViewController: navigatorViewController)
				m.minimumThickness		=	100
				m.preferredThicknessFraction	=	0.1
				m.automaticMaximumThickness	=	100
				m.canCollapse			=	true
				return m
			}
			func inspItem() -> NSSplitViewItem {
				let m = NSSplitViewItem(contentListWithViewController: inspectorViewController)
				m.minimumThickness		=	100
				m.preferredThicknessFraction	=	0.1
				m.automaticMaximumThickness	=	100
				m.canCollapse			=	true
				return m
			}
			func centerItem() -> NSSplitViewItem {
				let m = NSSplitViewItem(viewController: innerSplitViewController)
				m.minimumThickness		=	100
				m.preferredThicknessFraction	=	0.8
				m.automaticMaximumThickness	=	NSSplitViewItemUnspecifiedDimension
				return m
			}
			func consoleItem() -> NSSplitViewItem {
				let m = NSSplitViewItem(viewController: consoleViewController)
				m.minimumThickness		=	100
				m.preferredThicknessFraction	=	0.1
				m.automaticMaximumThickness	=	100
				m.canCollapse			=	true
				return m
			}
			func editItem() -> NSSplitViewItem {
				let m = NSSplitViewItem(viewController: textEditorViewController)
				m.minimumThickness		=	100
				m.preferredThicknessFraction	=	0.9
				m.automaticMaximumThickness	=	NSSplitViewItemUnspecifiedDimension
				return m
			}

                        addChildViewAndControllerImmediately(outerSplitViewController)
                        outerSplitViewController.splitViewItems = [
                                navItem(),
                                centerItem(),
				inspItem(),
                        ]
                        innerSplitViewController.splitView.vertical = false
                        innerSplitViewController.splitViewItems = [
                                editItem(),
				consoleItem(),
                        ]
                }
                textEditorViewController.textEditor = workspace.textEditor
                outerSplitViewController.view.frame = view.bounds
        }
}












