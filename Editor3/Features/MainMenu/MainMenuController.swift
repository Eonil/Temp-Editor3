//
//  MainMenuController.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/11/07.
//  Copyright © 2015 Eonil. All rights reserved.
//

import AppKit

final class MainMenuController {
	typealias Notification = EventNotification<MenuItemController,()>

        // MARK: -
        init(editor: Editor) {
                installMenuItems()
                installMainMenu()
                renderer = MainMenuRenderer(editor: editor, mainMenuController: self)
                processor = MainMenuProcessor(editor: editor, mainMenuController: self)
        }
        deinit {
                deinstallMainMenu()
                deinstallMenuItems()
        }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        // MARK: -
	// Keep menu item identifier length < 64.
	let	file				=	_instantiateGroupMenuItem("File")
	let	fileNew				=	_instantiateGroupMenuItem("New")
	let	fileNewWorkspace		=	_instantiateCommandMenuItem("Worksace...",		Command+Control+"N"		)
	let	fileNewFile			=	_instantiateCommandMenuItem("File...",			Command+"N"			)
	let	fileNewFolder			=	_instantiateCommandMenuItem("Folder...",		Command+Alternate+"N"		)
	let	fileOpen			=	_instantiateGroupMenuItem("Open")
	let	fileOpenWorkspace		=	_instantiateCommandMenuItem("Workspace...", 		Command+"O"			)
	let	fileOpenClearWorkspaceHistory	=	_instantiateCommandMenuItem("Clear Recent Workspaces",	nil	 			)
	let	fileCloseCurrentFile		=	_instantiateCommandMenuItem("Close File",		Command+Shift+"W"		)
	let	fileCloseCurrentWorkspace	=	_instantiateCommandMenuItem("Close Workspace",		Command+"W"			)
	let	fileDelete			=	_instantiateCommandMenuItem("Delete",			Command+Delete			)
	let	fileShowInFinder		=	_instantiateCommandMenuItem("Show in Finder", 		nil				)
	let	fileShowInTerminal		=	_instantiateCommandMenuItem("Show in Terminal",		nil				)

	let	view				=	_instantiateGroupMenuItem("View")
	let	viewEditor			=	_instantiateCommandMenuItem("Editor",			Command+"\n"			)
	let	viewNavigators			=	_instantiateGroupMenuItem("Navigators")
	let	viewShowProjectNavivator	=	_instantiateCommandMenuItem("Show File Navigator",	Command+"1"			)
	let	viewShowIssueNavivator		=	_instantiateCommandMenuItem("Show Issue Navigator",	Command+"2"			)
	let	viewShowDebugNavivator		=	_instantiateCommandMenuItem("Show Debug Navigator",	Command+"3"			)
	let	viewHideNavigator		=	_instantiateCommandMenuItem("Hide Navigator", 		Command+"0"			)
	let	viewConsole			=	_instantiateCommandMenuItem("Logs", 			Command+Shift+"C"		)
	let	viewFullscreen			=	_instantiateCommandMenuItem("Toggle Full Screen",	Command+Control+"F"		)

        let	editor				=	_instantiateGroupMenuItem("Editor")
        let	editorShowCompletions		=	_instantiateCommandMenuItem("Show Completions", 	Command+" ")

	let	product				=	_instantiateGroupMenuItem("Product")
	let	productRun			=	_instantiateCommandMenuItem("Run",			Command+"R"			)
	let	productBuild			=	_instantiateCommandMenuItem("Build",			Command+"B"			)
	let	productClean			=	_instantiateCommandMenuItem("Clean",			Command+Shift+"K"		)
	let	productStop			=	_instantiateCommandMenuItem("Stop",			Command+"."			)

	let	debug				=	_instantiateGroupMenuItem("Debug")
	let	debugPause			=	_instantiateCommandMenuItem("Pause",			Command+Control+"Y"		)
	let	debugResume			=	_instantiateCommandMenuItem("Resume",			Command+Control+"Y"		)
	let	debugHalt			=	_instantiateCommandMenuItem("Halt",			nil				)

	let	debugStepInto			=	_instantiateCommandMenuItem("Step Into",		_legacyFunctionKeyShortcut(NSF6FunctionKey))
	let	debugStepOut			=	_instantiateCommandMenuItem("Step Out",			_legacyFunctionKeyShortcut(NSF7FunctionKey))
	let	debugStepOver			=	_instantiateCommandMenuItem("Step Over",		_legacyFunctionKeyShortcut(NSF8FunctionKey))

	let	debugClearConsole		=	_instantiateCommandMenuItem("Clear Console", 		Command+"K"			)





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        // MARK: -
        private var renderer: MainMenuRenderer?
        private var processor: MainMenuProcessor?
	private func installMenuItems() {
		file.addSubmenuItems([
			fileNew,
			fileOpen,
			_instantiateSeparatorMenuItem(),
			fileCloseCurrentFile,
			fileCloseCurrentWorkspace,
			_instantiateSeparatorMenuItem(),
			fileDelete,
			fileShowInFinder,
			fileShowInTerminal,
			])
		fileNew.addSubmenuItems([
			fileNewWorkspace,
			fileNewFile,
			fileNewFolder,
			])
		fileOpen.addSubmenuItems([
			fileOpenWorkspace,
			fileOpenClearWorkspaceHistory,
			])

		view.addSubmenuItems([
			viewEditor,
			viewNavigators,
			viewConsole,
			_instantiateSeparatorMenuItem(),
			viewFullscreen,
			])
		viewNavigators.addSubmenuItems([
			viewShowProjectNavivator,
			viewShowIssueNavivator,
			viewShowDebugNavivator,
			_instantiateSeparatorMenuItem(),
			viewHideNavigator,
			])

                editor.addSubmenuItems([
                        editorShowCompletions,
                        ])

		product.addSubmenuItems([
			productRun,
			productBuild,
			productClean,
			_instantiateSeparatorMenuItem(),
			productStop,
			])

		debug.addSubmenuItems([
			debugPause,
			debugResume,
			debugHalt,
			_instantiateSeparatorMenuItem(),
			debugStepInto,
			debugStepOut,
			debugStepOver,
			_instantiateSeparatorMenuItem(),
			debugClearConsole,
			])
	}
	private func deinstallMenuItems() {
	}
	private func deinstallMainMenu() {
		assert(NSApplication.sharedApplication().mainMenu != nil, "Main menu is not yet set.")
		NSApplication.sharedApplication().mainMenu = nil
	}
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
                        appMenu.addItemWithTitle("Services", action: nil, keyEquivalent: "")!.submenu	=	appServicesMenu
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
		mainMenu.addItem(file.menuItem)
		mainMenu.addItem(view.menuItem)
                mainMenu.addItem(editor.menuItem)
		mainMenu.addItem(product.menuItem)
		mainMenu.addItem(debug.menuItem)

		NSApplication.sharedApplication().mainMenu = mainMenu
	}
}






























private func _legacyFunctionKeyShortcut(utf16CodeUnit: Int) -> MenuShortcutKeyCombination {
	return	MenuShortcutKeyCombination(legacyUTF16CodeUnit: unichar(utf16CodeUnit))
}

private func _instantiateGroupMenuItem(title: String) -> MenuItemController {
	let	sm		=	NSMenu(title: title)
	sm.autoenablesItems	=	false

	let	m		=	MenuItemController()
	m.menuItem.enabled	=	true
	m.menuItem.title	=	title
	m.menuItem.submenu	=	sm
	m.onClick		=	nil
	return	m
}

private func _instantiateCommandMenuItem(title: String, _ shortcut: MenuShortcutKeyCombination?) -> MenuItemController {
	let	m		=	MenuItemController()
	m.menuItem.title	=	title

	if let shortcut = shortcut {
		m.menuItem.keyEquivalent			=	shortcut.plainTextKeys
		m.menuItem.keyEquivalentModifierMask	=	Int(bitPattern: shortcut.modifierMask)
	}
	m.onClick = { [weak m] in
		guard let m = m else {
			return
		}
		EventNotification<MenuItemController,()>(sender: m, event: ()).broadcast()
	}
	return	m
}

private func _instantiateSeparatorMenuItem() -> MenuItemController {
	let	m		=	MenuItemController(menuItem: NSMenuItem.separatorItem())
	return	m
}

















































//private let	Delete		=	String(Character(UnicodeScalar(NSDeleteCharacter)))
private let	Delete		=	"\u{0008}"

private let	Command		=	MenuShortcutKeyCombination.Command
private let	Control		=	MenuShortcutKeyCombination.Control
private let	Alternate	=	MenuShortcutKeyCombination.Alternate
private let	Shift		=	MenuShortcutKeyCombination.Shift












