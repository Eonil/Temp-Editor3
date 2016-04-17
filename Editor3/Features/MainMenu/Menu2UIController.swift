////
////  Menu2UIController.swift
////  Editor3
////
////  Created by Hoon H. on 2016/04/17.
////  Copyright © 2016 Eonil. All rights reserved.
////
//
//import Foundation
//import AppKit
//
//final class Menu2UIController {
//        init() {
//                topMenuItemControllers = Menu2Code.topMenuItems().map { Menu2ItemController(code: $0) }
//                for c in topMenuItemControllers {
//                        c.putAllCodeToControllersIntoMapping(&codeToControllersMapping)
//                }
//
//                assert(editor != nil)
//                preconditionAndReportFailureToDevelopers(editor != nil)
//                render()
//                Editor.Event.Notification.register			(self, self.dynamicType.process)
//                Workspace.Event.Notification.register			(self, self.dynamicType.process)
//                TextEditor.Event.Notification.register			(self, self.dynamicType.process)
//                Builder.Event.Notification.register			(self, self.dynamicType.process)
//                Debugger.Event.Notification.register			(self, self.dynamicType.process)
//        }
//        deinit {
//                assert(editor != nil)
//                Debugger.Event.Notification.deregister			(self)
//                Builder.Event.Notification.deregister			(self)
//                TextEditor.Event.Notification.deregister		(self)
//                Workspace.Event.Notification.deregister			(self)
//                Editor.Event.Notification.deregister			(self)
//        }
//        func getTopLevelMenuItems() -> [NSMenuItem] {
//                return topMenuItemControllers.map { $0.item }
//        }
//
//        ////////////////////////////////////////////////////////////////
//
//        private let topMenuItemControllers: [Menu2ItemController]
//        private var codeToControllersMapping: [Menu2Code: [Menu2ItemController]]
//
//        // Keep menu item identifier length < 64.
//        private let file				=	Menu2ItemController(code: .File)
//        private let fileNew				=	Menu2ItemController(code: .FileNew)
//        private let fileNewWorkspace                    =	Menu2ItemController(code: .FileNewWorkspace)
//        private let fileNewFolder			=	Menu2ItemController(code: .FileNewFolder)
//        private let fileNewFile                         =	Menu2ItemController(code: .FileNewFile)
//        private let fileOpen                            =	Menu2ItemController(code: .FileOpen)
//        private let fileOpenWorkspace                   =	Menu2ItemController(code: .FileOpenWorkspace)
//        private let fileOpenClearWorkspaceHistory	=	Menu2ItemController(code: .FileOpenClearWorkspaceHistory)
//        private let fileCloseFile                       =	Menu2ItemController(code: .FileCloseFile)
//        private let fileCloseWorkspace                  =	Menu2ItemController(code: .FileCloseWorkspace)
//        private let fileDelete                          =	Menu2ItemController(code: .FileDelete)
//        private let fileShowInFinder                    =	Menu2ItemController(code: .FileShowInFinder)
//        private let fileShowInTerminal                  =	Menu2ItemController(code: .FileShowInTerminal)
//
//        private let view				=	Menu2ItemController(code: .View)
//        private let viewEditor                          =	Menu2ItemController(code: .ViewEditor)
//        private let viewNavigators			=	Menu2ItemController(code: .ViewShowNavigator)
//        private let viewShowProjectNavigator            =	Menu2ItemController(code: .ViewShowProjectNavigator)
//        private let viewShowIssueNavigator		=	Menu2ItemController(code: .ViewShowIssueNavigator)
//        private let viewShowDebugNavigator		=	Menu2ItemController(code: .ViewShowDebugNavigator)
//        private let viewHideNavigator                   =	Menu2ItemController(code: .ViewHideNavigator)
//        private let viewConsole                         =	Menu2ItemController(code: .ViewConsole)
//        private let viewFullScreen			=	Menu2ItemController(code: .ViewFullScreen)
//
//        private let editor				=	Menu2ItemController(code: .Editor)
//        private let editorShowCompletions		=	Menu2ItemController(code: .EditorShowCompletions)
//
//        private let product				=	Menu2ItemController(code: .Product)
//        private let productRun                          =	Menu2ItemController(code: .ProductRun)
//        private let productBuild			=	Menu2ItemController(code: .ProductBuild)
//        private let productClean			=	Menu2ItemController(code: .ProductClean)
//        private let productStop                         =	Menu2ItemController(code: .ProductStop)
//
//        private let debug				=	Menu2ItemController(code: .Debug)
//        private let debugPause                          =	Menu2ItemController(code: .DebugPause)
//        private let debugResume                         =	Menu2ItemController(code: .DebugResume)
//        private let debugHalt                           =	Menu2ItemController(code: .DebugHalt)
//
//        private let debugStepInto			=	Menu2ItemController(code: .DebugStepInto)
//        private let debugStepOut			=	Menu2ItemController(code: .DebugStepOut)
//        private let debugStepOver			=	Menu2ItemController(code: .DebugStepOver)
//        
//        private let debugClearConsole                   =	Menu2ItemController(code: .DebugClearConsole)
//
//
//        private weak var editor: Editor?
//        private func process(n: Editor.Event.Notification) {
//                render()
////                renderFileMenu()
////                renderViewMenu()
////                renderDebuggingMenu()
////                renderProductMenu()
//        }
//        private func process(n: Workspace.Event.Notification) {
//                renderFileMenu()
//                renderViewMenu()
//                renderProductMenu()
//        }
//        private func process(n: TextEditor.Event.Notification) {
//                renderFileMenu()
//                renderEditorMenu()
//        }
//	private func process(n: Builder.Event.Notification) {
//                renderFileMenu()
//                renderProductMenu()
//	}
//        private func process(n: Debugger.Event.Notification) {
//                guard n.sender ==== editor?.mainWorkspace?.debugger else { return }
//                renderDebuggingMenu()
//                renderProductMenu()
//	}
//
//	// MARK: -
//        private func render() {
//                renderFileMenu()
//                renderViewMenu()
//                renderEditorMenu()
//                renderProductMenu()
//                renderDebuggingMenu()
//        }
//        private func renderFileMenu() {
//                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//                setEnabledForCode(.FileNewWorkspace, enabled: true)
//                setEnabledForCode(<#T##code: Menu2Code##Menu2Code#>, enabled: <#T##Bool#>)
//                getItemController(.FileNewWorkspace).enabled    =       true
//                getItemController(<#T##code: Menu2Code##Menu2Code#>)
//		fileNewWorkspace.enabled		=	true
//		fileNewFile.enabled			=	editor.mainWorkspace?.fileNavigator.canCreateNewFile() ?? false
//		fileNewFolder.enabled		=	editor.mainWorkspace?.fileNavigator.canCreateNewFolder() ?? false
//		fileOpenWorkspace.enabled		=	true
//		fileCloseCurrentWorkspace.enabled	=	editor.mainWorkspace != nil
//		fileDelete.enabled			=	(editor.mainWorkspace?.fileNavigator.selection.count ?? 0) > 0
//		fileShowInFinder.enabled		=	editor.mainWorkspace?.fileNavigator.canShowInFinder() ?? false
//		fileShowInTerminal.enabled		=	editor.mainWorkspace?.fileNavigator.canShowInTerminal() ?? false
//	}
//	private func renderViewMenu() {
//                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//		let hasKeyWorkspace					=	editor.mainWorkspace != nil
//		mainMenuController.viewEditor.enabled			=	(editor.mainWorkspace?.fileNavigator.selection.count ?? 0) > 0
//		mainMenuController.viewShowProjectNavivator.enabled	=	hasKeyWorkspace
//		mainMenuController.viewShowIssueNavivator.enabled	=	hasKeyWorkspace
//		mainMenuController.viewShowDebugNavivator.enabled	=	hasKeyWorkspace
//		mainMenuController.viewHideNavigator.enabled		=	hasKeyWorkspace
//		mainMenuController.viewConsole.enabled			=	hasKeyWorkspace
//		mainMenuController.viewFullscreen.enabled		=	hasKeyWorkspace
//	}
//        private func renderEditorMenu() {
//                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//                mainMenuController.editorShowCompletions.enabled	=	editor.mainWorkspace?.textEditor.editingFileURL != nil
//        }
//
//        private func renderProductMenu() {
//                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
//                let isBuilding = editor.mainWorkspace?.builder.state == Optional(.Running)
//                let isDebugging = editor.mainWorkspace?.debugger.state == Optional(.Running)
//		mainMenuController.productRun.enabled			=	isBuilding == false
//		mainMenuController.productBuild.enabled			=	isBuilding == false
//		mainMenuController.productClean.enabled			=	isBuilding == false
//		mainMenuController.productStop.enabled			=	isBuilding || isDebugging
//	}
//        private func renderDebuggingMenu() {
////                guard let editor = editor else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
////                guard let mainMenuController = mainMenuController else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
////		let cmds = editor.mainWorkspace?.debug.currentTarget?.execution?.runnableCommands ?? []
////		mainMenuController.debugPause.enabled			=	cmds.contains(.Pause)
////		mainMenuController.debugResume.enabled			=	cmds.contains(.Resume)
////		mainMenuController.debugHalt.enabled			=	cmds.contains(.Halt)
////		mainMenuController.debugStepInto.enabled		=	cmds.contains(.StepInto)
////		mainMenuController.debugStepOut.enabled		=	cmds.contains(.StepOut)
////		mainMenuController.debugStepOver.enabled		=	cmds.contains(.StepOver)
////		mainMenuController.debugClearConsole.enabled		=	true
//        }
//
//        ////////////////////////////////////////////////////////////////
//
//        private func setEnabledForCode(code: Menu2Code, enabled: Bool) {
//                for c in (codeToControllersMapping[code] ?? []) {
//                        c.enabled = enabled
//                }
//        }
////        private func getItemController(code: Menu2Code) -> Menu2ItemController {
////                let cs = codeToControllersMapping[code] ?? []
////                guard cs.count <= 1 else {
////                        reportToDevelopers()
////                        fatalError()
////                }
////                return cs[0]
////        }
//
//}
//
//
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// MARK: -
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//private final class Menu2ItemController: NSObject {
//        let code: Menu2Code
//        let item: NSMenuItem
//        var subcontrollers: [Menu2ItemController]
//        var onEvent: (Menu2Code->())?
//        init(code: Menu2Code) {
//                self.code = code
//                switch code {
//                case .Separator:
//                        item = NSMenuItem.separatorItem()
//                        subcontrollers = []
//                        super.init()
//                default:
//                        item = NSMenuItem()
//                        subcontrollers = []
//                        super.init()
//                        item.enabled = false
//                        item.title = code.getLabel()
//                        item.keyEquivalentModifierMask = Int(bitPattern: code.getKeyModifiersAndEquivalentPair().keyModifier.rawValue)
//                        item.keyEquivalent = code.getKeyModifiersAndEquivalentPair().keyEquivalent
//                        item.target = self
//                        item.action = #selector(EDITOR_onClick(_:))
//                        subcontrollers = code.getSubmenuItems().map({ Menu2ItemController(code: $0) })
//                        if code.getSubmenuItems().count > 0 {
//                                let m = NSMenu()
//                                m.autoenablesItems = false
//                                item.submenu = m
//                        }
//                }
//        }
//        var enabled: Bool {
//                get {
//                        return item.enabled
//                }
//                set {
//                        item.enabled = newValue
//                }
//        }
//        func putAllCodeToControllersIntoMapping(inout mapping: [Menu2Code: [Menu2ItemController]]) {
//                var list = mapping[code] ?? []
//                list.append(self)
//                mapping[code] = list
//                for s in subcontrollers {
//                        s.putAllCodeToControllersIntoMapping(&mapping)
//                }
//        }
//        private func render() {
//
//        }
//        @objc
//        private func EDITOR_onClick(_: AnyObject?) {
//                assert(onEvent != nil)
//                onEvent?(code)
//                Menu2Code.Notification.broadcast(code)
//        }
//}
//private extension Menu2Code {
//        func makeItemController() -> Menu2ItemController {
//                return Menu2ItemController(code: self)
//        }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
