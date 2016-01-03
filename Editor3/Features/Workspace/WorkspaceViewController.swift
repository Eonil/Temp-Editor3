//
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
        override func viewDidLayout() {
                super.viewDidLayout()
                render()
        }

        // MARK: -
        private let outerSplitViewController = NSSplitViewController()
        private let innerSplitViewController = NSSplitViewController()
	private let navigatorViewController = NavigatorViewController()
        private let fileNavigatorViewController = FileNavigatorViewController()
        private let textEditorViewController = TextEditorViewController()
        private var installer = ViewInstaller()
        private func render() {
                guard let workspace = workspace else { return }
                installer.installIfNeeded {
//                        outerSplitViewController.splitView.wantsLayer = true
//                        innerSplitViewController.splitView.wantsLayer = true
                        addChildViewAndControllerImmediately(outerSplitViewController)
                        outerSplitViewController.splitViewItems = [
                                NSSplitViewItem(sidebarWithViewController: navigatorViewController),
                                NSSplitViewItem(viewController: innerSplitViewController),
                        ]
                        innerSplitViewController.splitView.vertical = true
                        innerSplitViewController.splitViewItems = [
                                NSSplitViewItem(viewController: textEditorViewController),
                        ]
                }
                textEditorViewController.textEditor = workspace.textEditor
                outerSplitViewController.view.frame = view.bounds
        }
}













