//
//  MainMenuController.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/11/07.
//  Copyright © 2015 Eonil. All rights reserved.
//

import AppKit

final class MainMenuController {

        weak var editor: Editor? {
                didSet {
                        render()
                }
        }
        weak var ADHOC_editorUIComponentResolver: ADHOC_EditorUIComponentResolver? {
                didSet {
                        render()
                }
        }

        ////////////////////////////////////////////////////////////////

        init() {
                installMainMenu()
                Editor.Event.Notification.register      (self, self.dynamicType.process)
                Workspace.Event.Notification.register	(self, self.dynamicType.process)
                TextEditor.Event.Notification.register	(self, self.dynamicType.process)
                Builder.Event.Notification.register	(self, self.dynamicType.process)
                Debugger.Event.Notification.register	(self, self.dynamicType.process)
        }
        deinit {
                Debugger.Event.Notification.deregister	(self)
                Builder.Event.Notification.deregister	(self)
                TextEditor.Event.Notification.deregister(self)
                Workspace.Event.Notification.deregister	(self)
                Editor.Event.Notification.deregister	(self)
                deinstallMainMenu()
        }

        ////////////////////////////////////////////////////////////////

        private let palette = MenuItemPalette()

        ////////////////////////////////////////////////////////////////

        private func installMainMenu() {
                assert(NSApplication.sharedApplication().mainMenu == nil, "Main menu already been set.")

                func getApplicationMenu() -> NSMenu {
                        let appName = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as! String
                        let appMenu = NSMenu()

                        let appServicesMenu = NSMenu()
                        NSApp.servicesMenu = appServicesMenu
                        appMenu.addItemWithTitle("About \(appName)", action: nil, keyEquivalent: "")
                        appMenu.addItem(NSMenuItem.separatorItem())
                        appMenu.addItemWithTitle("Preferences...", action: nil, keyEquivalent: ",")
                        appMenu.addItem(NSMenuItem.separatorItem())
                        appMenu.addItemWithTitle("Hide \(appName)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
                        appMenu.addItem({ ()->NSMenuItem in
                                let m	=	NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
                                m.keyEquivalentModifierMask	=	Int(NSEventModifierFlags([.CommandKeyMask, .AlternateKeyMask]).rawValue)
                                return	m
                                }())
                        appMenu.addItemWithTitle("Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
                        appMenu.addItem(NSMenuItem.separatorItem())
                        appMenu.addItemWithTitle("Services", action: nil, keyEquivalent: "")!.submenu = appServicesMenu
                        appMenu.addItem(NSMenuItem.separatorItem())
                        appMenu.addItemWithTitle("Quit \(appName)", action: #selector(NSApplication.terminate), keyEquivalent: "q")

			return appMenu
                }
                // `title` really doesn't matter.
                let mainMenu = NSMenu()
                // `title` really doesn't matter.
                let mainAppMenuItem = NSMenuItem(title: "Application", action: nil, keyEquivalent: "")
                mainMenu.addItem(mainAppMenuItem)
                // `title` really doesn't matter.
                mainAppMenuItem.submenu = getApplicationMenu()
                for c in palette.topLevelMenuItemControllers() {
                        mainMenu.addItem(c.item)
                }
		NSApplication.sharedApplication().mainMenu = mainMenu
	}
        private func deinstallMainMenu() {
                assert(NSApplication.sharedApplication().mainMenu != nil, "Main menu is not yet set.")
                NSApplication.sharedApplication().mainMenu = nil
        }

        ////////////////////////////////////////////////////////////////

        private func process(n: Editor.Event.Notification) {
                render()
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
                guard n.sender ==== editor?.mainWorkspace?.debugger else { return }
                renderDebuggingMenu()
                renderProductMenu()
        }

        private func processUserClickingOfMenuForCode(code: Menu2Code) {
                guard let editor = editor else { return }
                switch code {
                case .FileNewWorkspace: do {
			let newWorkspace = Workspace()
			editor.addWorkspace(newWorkspace)
//                        NSDocumentController.sharedDocumentController().newDocument(self)
//                        Dialogue.runSavingWorkspace { [weak self] in
//                                guard self != nil else {
//                                        return
//                                }
//                                if let u = $0 {
//                                        try! self!.model!.createAndOpenWorkspaceAtURL(u)
//                                }
//                        }
                        }

                case .FileNewFolder:
                        assert(editor.mainWorkspace != nil)
                        assert(editor.mainWorkspace!.fileNavigator.canCreateNewFolder())
                        guard let workspace = editor.mainWorkspace else { return }
                        do {
                                try workspace.fileNavigator.createNewFolder()
                        }
                        catch let error {
                                reportToDevelopers(error)
                                if let error = error as? EditorCommonUIPresentableErrorType { presentError(error, inWindowForWorkspace: workspace) }
                        }

                case .FileNewFile:
                        assert(editor.mainWorkspace != nil)
                        assert(editor.mainWorkspace!.fileNavigator.canCreateNewFile())
                        guard let workspace = editor.mainWorkspace else { return }
                        do {
                                try workspace.fileNavigator.createNewFile()
                        }
                        catch let error {
                                reportToDevelopers(error)
                                if let error = error as? EditorCommonUIPresentableErrorType { presentError(error, inWindowForWorkspace: workspace) }
                        }

		case .FileDelete:
                        assert(editor.mainWorkspace != nil)
                        assert(editor.mainWorkspace!.fileNavigator.canDelete())
                        checkAndReportFailureToDevelopers(editor.mainWorkspace != nil)
                        guard let workspace = editor.mainWorkspace else { return }
                        guard let workspaceDocument = ADHOC_editorUIComponentResolver?.findWorkspaceDocumentForWorkspace(workspace) else { return }
                        guard let window = workspaceDocument.workspaceWindowController.window else { return }
                        let message = workspace.fileNavigator.selection.count == 1
                                ? "Do you want to delete this file?"
                                : "Do you want to delete these files?"
                        let information = workspace.fileNavigator.selection.map({ $0.name }).joinWithSeparator("\n")
                        let proceed = { [weak workspace, weak window] in
                                do {
                                        try workspace?.fileNavigator.delete()
                                }
                                catch let error {
                                        reportToDevelopers(error)
                                        if let error = error as? EditorCommonUIPresentableErrorType {
                                                window?.presentError(error.toUIPresentableError())
                                        }
                                }
                        }
                        window.runConfirmWithMessageText(message,
                                                         informativeText: information,
                                                         proceedButtonTitle: "Delete",
                                                         onProceed: proceed)

		case .FileShowInFinder:
                        assert(editor.mainWorkspace != nil)
                        assert(editor.mainWorkspace!.fileNavigator.canShowInFinder())
                        checkAndReportFailureToDevelopers(editor.mainWorkspace != nil)
                        guard let workspace = editor.mainWorkspace else { return }
                        workspace.fileNavigator.showInFinder()

		case .FileShowInTerminal:
                        assert(editor.mainWorkspace != nil)
                        assert(editor.mainWorkspace!.fileNavigator.canShowInTerminal())
                        checkAndReportFailureToDevelopers(editor.mainWorkspace != nil)
                        guard let workspace = editor.mainWorkspace else { return }
                        workspace.fileNavigator.showInTerminal()

//                case .FileOpenWorkspace:
//                        Dialogue.runOpeningWorkspace() { [weak self] in
//                                guard self != nil else {
//                                        return
//                                }
//                                if let u = $0 {
//                                        self!.model!.openWorkspaceAtURL(u)
//                                }
//                        }
//
                case .FileCloseWorkspace:
                        assert(editor.mainWorkspace != nil)
                        guard let workspace = editor.mainWorkspace else { return }
                        editor.removeWorkspace(workspace)

//                case .FileCloseFile:


//                case .ViewEditor:
//                        editor.keyWorkspace!.overallUIState.paneSelection = .Editor
//
//                case .ViewShowProjectNavivator:
//                        editor.keyWorkspace!.overallUIState.mutate {
//                                $0.navigationPaneVisibility	=	true
//                                $0.paneSelection		=	WorkspaceUIState.Pane.Navigation(.Project)
//                        }
//
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

		case .EditorShowCompletions:
                        assert(editor.mainWorkspace != nil, "This menu must be disabled when inappropriate.")
                        guard let workspace = editor.mainWorkspace else { return }
                        do {
                                try workspace.textEditor.showCompletion()
                        }
                        catch let error {
                                debugLog(error)
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
                case .ProductBuild:
                        assert(editor.mainWorkspace != nil)
                        assert(editor.mainWorkspace!.builder.state != .Running)
                        guard let workspace = editor.mainWorkspace else { return }
                        guard workspace.builder.state != .Running else { return }
                        workspace.builder.runBuilding()

                case .ProductClean:
                        assert(editor.mainWorkspace != nil)
                        assert(editor.mainWorkspace!.builder.state != .Running)
                        guard let workspace = editor.mainWorkspace else { return }
                        guard workspace.builder.state != .Running else { return }
                        workspace.builder.runCleaning()
                        
                case .ProductStop:
                        assert(editor.mainWorkspace != nil)
                        assert(editor.mainWorkspace!.builder.state == .Running)
                        guard let workspace = editor.mainWorkspace else { return }
                        guard workspace.builder.state == .Running else { return }
                        workspace.builder.cancelRunningAnyway()
//                        assert(editor.keyWorkspace!.build.busy == false)
//                        editor.keyWorkspace!.debug.currentTarget!.halt()
//                        editor.keyWorkspace!.build.stop()

                        
                        
                        
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
                        MARK_unimplemented()
                        fatalError()
                }
        }
        private func presentError(error: EditorCommonUIPresentableErrorType, inWindowForWorkspace workspace: Workspace) {
                func getNearestResponder() -> NSResponder {
                        return ADHOC_editorUIComponentResolver?
                                .findWorkspaceDocumentForWorkspace(workspace)?
                                .workspaceWindowController
                                ?? NSApplication.sharedApplication()
                }
                getNearestResponder().presentError(error.toUIPresentableError())
        }

        ////////////////////////////////////////////////////////////////

        private var installer = ViewInstaller()
        private func render() {
                installer.installIfNeeded {
                        func setEventHandlerOfControllerRecursively(c: MenuItemController, handler: (Menu2Code)->()) {
                                c.onEvent = handler
                                for s in c.subcontrollers {
                                        setEventHandlerOfControllerRecursively(s, handler: handler)
                                }
                        }
                        for c in palette.topLevelMenuItemControllers() {
                                setEventHandlerOfControllerRecursively(c) { [weak self] in
                                        guard let S = self else { return }
                                        S.processUserClickingOfMenuForCode($0)
                                }
                        }
                }
                renderFileMenu()
                renderViewMenu()
                renderEditorMenu()
                renderProductMenu()
                renderDebuggingMenu()
        }
        private func renderFileMenu() {
                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                palette.file.enabled                            =       true
                palette.fileNew.enabled                         =       true
		palette.fileNewWorkspace.enabled		=	true
		palette.fileNewFile.enabled			=	editor.mainWorkspace?.fileNavigator.canCreateNewFile() ?? false
		palette.fileNewFolder.enabled                   =	editor.mainWorkspace?.fileNavigator.canCreateNewFolder() ?? false
		palette.fileOpenWorkspace.enabled		=	true
		palette.fileCloseWorkspace.enabled              =	editor.mainWorkspace != nil
		palette.fileDelete.enabled			=	(editor.mainWorkspace?.fileNavigator.selection.count ?? 0) > 0
		palette.fileShowInFinder.enabled		=	editor.mainWorkspace?.fileNavigator.canShowInFinder() ?? false
		palette.fileShowInTerminal.enabled		=	editor.mainWorkspace?.fileNavigator.canShowInTerminal() ?? false
	}
	private func renderViewMenu() {
                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		let hasKeyWorkspace				=	editor.mainWorkspace != nil
                palette.view.enabled                            =       true
		palette.viewEditor.enabled			=	(editor.mainWorkspace?.fileNavigator.selection.count ?? 0) > 0
                palette.viewNavigators.enabled                  =       true
		palette.viewShowProjectNavigator.enabled	=	hasKeyWorkspace
		palette.viewShowIssueNavigator.enabled          =	hasKeyWorkspace
		palette.viewShowDebugNavigator.enabled          =	hasKeyWorkspace
		palette.viewHideNavigator.enabled		=	hasKeyWorkspace
		palette.viewConsole.enabled			=	hasKeyWorkspace
		palette.viewFullScreen.enabled                  =	hasKeyWorkspace
	}
        private func renderEditorMenu() {
                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                palette.editor.enabled                          =       true
                palette.editorShowCompletions.enabled           =	editor.mainWorkspace?.textEditor.editingFileURL != nil
        }

        private func renderProductMenu() {
                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                let isBuilding = editor.mainWorkspace?.builder.state == Optional(.Running)
                let isDebugging = editor.mainWorkspace?.debugger.state == Optional(.Running)
                palette.product.enabled                         =       true
		palette.productRun.enabled			=	isBuilding == false
		palette.productBuild.enabled			=	isBuilding == false
		palette.productClean.enabled			=	isBuilding == false
		palette.productStop.enabled			=	isBuilding || isDebugging
	}
        private func renderDebuggingMenu() {
//                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//		let cmds = editor.mainWorkspace?.debug.currentTarget?.execution?.runnableCommands ?? []
//		palette.debugPause.enabled			=	cmds.contains(.Pause)
//		palette.debugResume.enabled			=	cmds.contains(.Resume)
//		palette.debugHalt.enabled			=	cmds.contains(.Halt)
//		palette.debugStepInto.enabled		=	cmds.contains(.StepInto)
//		palette.debugStepOut.enabled		=	cmds.contains(.StepOut)
//		palette.debugStepOver.enabled		=	cmds.contains(.StepOver)
//		palette.debugClearConsole.enabled		=	true
        }
}


















































