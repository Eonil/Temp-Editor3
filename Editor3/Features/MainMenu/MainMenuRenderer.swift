//
//  MainMenuAvailabilityManager.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/11/07.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Renders main menu state according to model event and states.
final class MainMenuRenderer {
	init(editor: Editor, mainMenuController: MainMenuController) {
                self.editor = editor
                self.mainMenuController = mainMenuController
                _install()
	}
	deinit {
                _deinstall()
	}

	// MARK: -
        private weak var editor: Editor?
        private weak var mainMenuController: MainMenuController?
	private func _install() {
                assert(editor != nil)
                preconditionAndReportFailureToDevelopers(editor != nil)
                render()
		Editor.Event.Notification.register			(self, self.dynamicType.process)
		Workspace.Event.Notification.register			(self, self.dynamicType.process)
                TextEditor.Event.Notification.register			(self, self.dynamicType.process)
		Builder.Event.Notification.register			(self, self.dynamicType.process)
                Debugger.Event.Notification.register			(self, self.dynamicType.process)
	}
	private func _deinstall() {
                assert(editor != nil)
		Debugger.Event.Notification.deregister			(self)
		Builder.Event.Notification.deregister			(self)
                TextEditor.Event.Notification.deregister		(self)
		Workspace.Event.Notification.deregister			(self)
		Editor.Event.Notification.deregister			(self)
        }

        private func process(n: Editor.Event.Notification) {
                render()
//                renderFileMenu()
//                renderViewMenu()
//                renderDebuggingMenu()
//                renderProductMenu()
        }
        private func process(n: Workspace.Event.Notification) {
                renderFileMenu()
                renderViewMenu()
                renderProductMenu()
        }
        private func process(n: TextEditor.Event.Notification) {
                renderFileMenu()
                renderEditorMenu()
        }
	private func process(n: Builder.Event.Notification) {
                renderFileMenu()
                renderProductMenu()
	}
        private func process(n: Debugger.Event.Notification) {
                guard n.sender === editor?.mainWorkspace?.debugger else { return }
                renderDebuggingMenu()
                renderProductMenu()
	}

	// MARK: -
        private func render() {
                renderFileMenu()
                renderViewMenu()
                renderEditorMenu()
                renderProductMenu()
                renderDebuggingMenu()
        }
        private func renderFileMenu() {
                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		mainMenuController.fileNewWorkspace.enabled		=	true
		mainMenuController.fileNewFile.enabled			=	editor.mainWorkspace?.fileNavigator.canCreateNewFile() ?? false
		mainMenuController.fileNewFolder.enabled		=	editor.mainWorkspace?.fileNavigator.canCreateNewFolder() ?? false
		mainMenuController.fileOpenWorkspace.enabled		=	true
		mainMenuController.fileCloseCurrentWorkspace.enabled	=	editor.mainWorkspace != nil
		mainMenuController.fileDelete.enabled			=	(editor.mainWorkspace?.fileNavigator.selection.count ?? 0) > 0
		mainMenuController.fileShowInFinder.enabled		=	editor.mainWorkspace?.fileNavigator.canShowInFinder() ?? false
		mainMenuController.fileShowInTerminal.enabled		=	editor.mainWorkspace?.fileNavigator.canShowInTerminal() ?? false
	}
	private func renderViewMenu() {
                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		let hasKeyWorkspace					=	editor.mainWorkspace != nil
		mainMenuController.viewEditor.enabled			=	(editor.mainWorkspace?.fileNavigator.selection.count ?? 0) > 0
		mainMenuController.viewShowProjectNavivator.enabled	=	hasKeyWorkspace
		mainMenuController.viewShowIssueNavivator.enabled	=	hasKeyWorkspace
		mainMenuController.viewShowDebugNavivator.enabled	=	hasKeyWorkspace
		mainMenuController.viewHideNavigator.enabled		=	hasKeyWorkspace
		mainMenuController.viewConsole.enabled			=	hasKeyWorkspace
		mainMenuController.viewFullscreen.enabled		=	hasKeyWorkspace
	}
        private func renderEditorMenu() {
                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                mainMenuController.editorShowCompletions.enabled	=	editor.mainWorkspace?.textEditor.editingFileURL != nil
        }

        private func renderProductMenu() {
                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                let isBuilding = editor.mainWorkspace?.builder.state == Optional(.Running)
                let isDebugging = editor.mainWorkspace?.debugger.state == Optional(.Running)
		mainMenuController.productRun.enabled			=	isBuilding == false
		mainMenuController.productBuild.enabled			=	isBuilding == false
		mainMenuController.productClean.enabled			=	isBuilding == false
		mainMenuController.productStop.enabled			=	isBuilding || isDebugging
	}
        private func renderDebuggingMenu() {
//                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//		let cmds = editor.mainWorkspace?.debug.currentTarget?.execution?.runnableCommands ?? []
//		mainMenuController.debugPause.enabled			=	cmds.contains(.Pause)
//		mainMenuController.debugResume.enabled			=	cmds.contains(.Resume)
//		mainMenuController.debugHalt.enabled			=	cmds.contains(.Halt)
//		mainMenuController.debugStepInto.enabled		=	cmds.contains(.StepInto)
//		mainMenuController.debugStepOut.enabled		=	cmds.contains(.StepOut)
//		mainMenuController.debugStepOver.enabled		=	cmds.contains(.StepOver)
//		mainMenuController.debugClearConsole.enabled		=	true
        }
}






























