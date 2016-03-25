//
//  MainMenuController+CommandProcessing.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/11/07.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class MainMenuProcessor {

        private typealias Notification = EventNotification<MenuItemController,()>
        init(editor: Editor, mainMenuController: MainMenuController) {
                self.editor = editor
                self.mainMenuController = mainMenuController
                Notification.register	(self, self.dynamicType.process)
        }
        deinit {
                Notification.deregister	(self)
        }

        private weak var editor: Editor?
        private weak var mainMenuController: MainMenuController?

	/// Observes main-menu command and applies proper mutations
	/// to model and view.
        private func process(n: Notification) {
                guard let editor = editor else { return }
                guard let mainMenuController = mainMenuController else { return }
                switch ~~n.sender {
                case ~~mainMenuController.fileNewWorkspace: do {
                        NSDocumentController.sharedDocumentController().newDocument(self)
//                        Dialogue.runSavingWorkspace { [weak self] in
//                                guard self != nil else {
//                                        return
//                                }
//                                if let u = $0 {
//                                        try! self!.model!.createAndOpenWorkspaceAtURL(u)
//                                }
//                        }
                        }

                case ~~mainMenuController.fileNewFile:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				assertMenuExecutabilityByChecking(editor.mainWorkspace!.fileNavigator.canCreateNewFile())
				guard let workspace = editor.mainWorkspace else { return }
				workspace.fileNavigator.createNewFile()
			}

		case ~~mainMenuController.fileNewFolder:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				assertMenuExecutabilityByChecking(editor.mainWorkspace!.fileNavigator.canCreateNewFolder())
				guard let workspace = editor.mainWorkspace else { return }
				workspace.fileNavigator.createNewFolder()
			}

		case ~~mainMenuController.fileDelete:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				assertMenuExecutabilityByChecking(editor.mainWorkspace!.fileNavigator.canDelete())
				checkAndReportFailureToDevelopers(editor.mainWorkspace != nil)
				guard let workspace = editor.mainWorkspace else { return }
				workspace.fileNavigator.delete()
			}

		case ~~mainMenuController.fileShowInFinder:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				assertMenuExecutabilityByChecking(editor.mainWorkspace!.fileNavigator.canShowInFinder())
				checkAndReportFailureToDevelopers(editor.mainWorkspace != nil)
				guard let workspace = editor.mainWorkspace else { return }
				workspace.fileNavigator.showInFinder()
			}

		case ~~mainMenuController.fileShowInTerminal:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				assertMenuExecutabilityByChecking(editor.mainWorkspace!.fileNavigator.canShowInTerminal())
				checkAndReportFailureToDevelopers(editor.mainWorkspace != nil)
				guard let workspace = editor.mainWorkspace else { return }
				workspace.fileNavigator.showInTerminal()
			}

//                case ~~mainMenuController.fileOpenWorkspace: do {
//                        Dialogue.runOpeningWorkspace() { [weak self] in
//                                guard self != nil else {
//                                        return
//                                }
//                                if let u = $0 {
//                                        self!.model!.openWorkspaceAtURL(u)
//                                }
//                        }
//                        }
//
                case ~~mainMenuController.fileCloseCurrentWorkspace:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				guard let workspace = editor.mainWorkspace else { return }
				guard let workspaceDocument = workspace.ownerDocument else { return }
				workspaceDocument.close()
				//                        NSDocumentController.sharedDocumentController().removeDocument(document)
			}


//                case ~~mainMenuController.viewEditor: do {
//                        editor.keyWorkspace!.overallUIState.paneSelection			=	.Editor
//                        }
//                case ~~mainMenuController.viewShowProjectNavivator: do {
//                        editor.keyWorkspace!.overallUIState.mutate {
//                                $0.navigationPaneVisibility	=	true
//                                $0.paneSelection		=	WorkspaceUIState.Pane.Navigation(.Project)
//                        }
//                        }
//                case ~~mainMenuController.viewShowIssueNavivator: do {
//                        editor.keyWorkspace!.overallUIState.mutate {
//                                $0.navigationPaneVisibility	=	true
//                                $0.paneSelection		=	WorkspaceUIState.Pane.Navigation(.Issue)
//                        }
//                        }
//                case ~~mainMenuController.viewShowDebugNavivator: do {
//                        editor.keyWorkspace!.overallUIState.mutate {
//                                $0.navigationPaneVisibility	=	true
//                                $0.paneSelection		=	WorkspaceUIState.Pane.Navigation(.Debug)
//                        }
//                        }
//                case ~~mainMenuController.viewHideNavigator: do {
//                        editor.keyWorkspace!.overallUIState.mutate {
//                                $0.navigationPaneVisibility	=	false
//                                ()
//                        }
//                        }
//                case ~~mainMenuController.viewConsole: do {
//                        editor.keyWorkspace!.overallUIState.mutate {
//                                $0.consolePaneVisibility	=	true
//                                ()
//                        }
//                        }
//                case ~~mainMenuController.viewFullscreen: do {
//                        NSApplication.sharedApplication().mainWindow?.toggleFullScreen(self)
//                        }

		case ~~mainMenuController.editorShowCompletions:
			do {
				assert(editor.mainWorkspace != nil, "This menu must be disabled when inappropriate.")
				guard let workspace = editor.mainWorkspace else { return }
				do {
					try workspace.textEditor.showCompletion()
				}
				catch let error {
					debugLog(error)
				}
                        }

//                case ~~mainMenuController.productRun: do {
//                        assert(editor.keyWorkspace!.build.busy == false)
//                        guard let workspace = editor.keyWorkspace else {
//                                fatalError()
//                        }
//                        if let target = workspace.debug.currentTarget {
//                                if target.execution != nil {
//                                        target.halt()
//                                }
//                                workspace.debug.deselectTarget(target)
//                        }
//                        if workspace.debug.targets.count == 0 {
//                                MARK_unimplemented("We need to query `Cargo.toml` file to get proper executable location.")
//                                if let u = workspace.location {
//                                        let	n	=	u.lastPathComponent!
//                                        let	u1	=	u.URLByAppendingPathComponent("target").URLByAppendingPathComponent("debug").URLByAppendingPathComponent(n)
//                                        workspace.debug.createTargetForExecutableAtURL(u1)
//                                }
//                        }
//                        
//                        workspace.debug.selectTarget(workspace.debug.targets.first!)
//                        workspace.debug.currentTarget!.launch(NSURL(fileURLWithPath: "."))
//                        }
//                        
                case ~~mainMenuController.productBuild:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				assertMenuExecutabilityByChecking(editor.mainWorkspace!.builder.state != .Running)
				guard let workspace = editor.mainWorkspace else { return }
				guard workspace.builder.state != .Running else { return }
				workspace.builder.runBuilding()
			}

                case ~~mainMenuController.productClean:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				assertMenuExecutabilityByChecking(editor.mainWorkspace!.builder.state != .Running)
				guard let workspace = editor.mainWorkspace else { return }
				guard workspace.builder.state != .Running else { return }
				workspace.builder.runCleaning()
                        }
                        
                case ~~mainMenuController.productStop:
			do {
				assertMenuExecutabilityByChecking(editor.mainWorkspace != nil)
				assertMenuExecutabilityByChecking(editor.mainWorkspace!.builder.state == .Running)
				guard let workspace = editor.mainWorkspace else { return }
				guard workspace.builder.state == .Running else { return }
				workspace.builder.cancelRunningAnyway()
//                        assert(editor.keyWorkspace!.build.busy == false)
//                        editor.keyWorkspace!.debug.currentTarget!.halt()
//                        editor.keyWorkspace!.build.stop()
                        }
                        
                        
                        
//                case ~~mainMenuController.debugPause: do {
//                        editor.keyWorkspace!.debug.currentTarget!.execution!.runCommand(.Pause)
//                        }
//                        
//                case ~~mainMenuController.debugResume: do {
//                        editor.keyWorkspace!.debug.currentTarget!.execution!.runCommand(.Resume)
//                        }
//                        
//                case ~~mainMenuController.debugHalt: do {
//                        editor.keyWorkspace!.debug.currentTarget!.execution!.runCommand(.Halt)
//                        }
//                        
//                case ~~mainMenuController.debugStepInto: do {
//                        editor.keyWorkspace!.debug.currentTarget!.execution!.runCommand(.StepInto)
//                        }
//                        
//                case ~~mainMenuController.debugStepOut: do {
//                        editor.keyWorkspace!.debug.currentTarget!.execution!.runCommand(.StepOut)
//                        }
//                        
//                case ~~mainMenuController.debugStepOver: do {
//                        editor.keyWorkspace!.debug.currentTarget!.execution!.runCommand(.StepOver)
//                        }
//                        
//                case ~~mainMenuController.debugClearConsole: do {
//                        editor.keyWorkspace!.console.clear()
//                        }
//                        q
//                case ~~mainMenuController.DEV_test1: do {
//                        
//                        }

                default:
                        fatalError("A menu command `\(n.sender)` has not been implemented.")
                }

		// Do not code anythig after the switch. 
		// Because this switch is intended to `return` control flow
		// for quick exit.
        }
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private func assertMenuExecutabilityByChecking(@autoclosure condition: ()->Bool) {
	assert(condition(), "The menu must be executable. Or must be disabled if inexecutable.")
}
prefix operator ~~ {
}
private prefix func ~~(a: MenuItemController) -> ObjectIdentifier {
	return	ObjectIdentifier(a)
}



















