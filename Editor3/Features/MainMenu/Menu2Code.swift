//
//  Menu2Enums.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/17.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

enum Menu2Code {
        case Separator
        case File
        case FileNew
        case FileNewWorkspace
        case FileNewFolder
        case FileNewFile
        case FileOpen
        case FileOpenWorkspace
        case FileOpenClearWorkspaceHistory
        case FileCloseFile
        case FileCloseWorkspace
        case FileDelete
        case FileShowInFinder
        case FileShowInTerminal
        case View
        case ViewEditor
        case ViewShowNavigator
        case ViewShowProjectNavigator
        case ViewShowIssueNavigator
        case ViewShowDebugNavigator
        case ViewHideNavigator
        case ViewConsole
        case ViewFullScreen
        case Editor
        case EditorShowCompletions
        case Product
        case ProductRun
        case ProductBuild
        case ProductClean
        case ProductStop
        case Debug
        case DebugPause
        case DebugResume
        case DebugHalt
        case DebugStepInto
        case DebugStepOut
        case DebugStepOver
        case DebugClearConsole
}
extension Menu2Code {
        typealias Notification = EventNotification<Menu2Code,()>
        static func topMenuItems() -> [Menu2Code] {
                return [
                        .File,
                        .View,
                        .Editor,
                        .Product,
                        .Debug,
                ]
        }
//        func getSubmenuItems() -> ([Menu2Code]) {
//                switch self {
//                case .File: return ([
//                        .FileNew,
//                        .FileOpen,
//                        .Separator,
//                        .FileCloseFile,
//                        .FileCloseWorkspace,
//                        .Separator,
//                        .FileDelete,
//                        .FileShowInFinder,
//                        .FileShowInTerminal,
//                        ])
//                case .FileNew: return ([
//                        .FileNewWorkspace,
//                        .FileNewFolder,
//                        .FileNewFile,
//                        ])
//                case .FileOpen: return ([
//                        .FileOpenWorkspace,
//                        .FileOpenClearWorkspaceHistory,
//                        ])
//                case .View: return ([
//                        .ViewEditor,
//                        .ViewShowNavigator,
//                        .ViewConsole,
//                        .Separator,
//                        .ViewFullScreen,
//                        ])
//                case .ViewShowNavigator: return ([
//                        .ViewShowProjectNavigator,
//                        .ViewShowIssueNavigator,
//                        .ViewShowDebugNavigator,
//                        .Separator,
//                        .ViewHideNavigator,
//                        ])
//                case .Editor: return ([
//                        .EditorShowCompletions,
//                        ])
//                case .Product: return ([
//                        .ProductRun,
//                        .ProductBuild,
//                        .ProductClean,
//                        .Separator,
//                        .ProductStop,
//                        ])
//                case .Debug: return ([
//                        .DebugPause,
//                        .DebugResume,
//                        .DebugHalt,
//                        .Separator,
//                        .DebugStepInto,
//                        .DebugStepOut,
//                        .DebugStepOver,
//                        .DebugStepOut,
//                        .Separator,
//                        .DebugClearConsole,
//                        ])
//                default: return ([])
//                }
//        }

        func getLabel() -> String {
                switch self {
                case .Separator:                        fatalError("Separator cannot have a text label.")
                case .File:                             return "File"
                case .FileNew:                          return "New"
                case .FileNewWorkspace:			return "Workspace..."
                case .FileNewFolder:                    return "Folder..."
                case .FileNewFile:                      return "File..."
                case .FileOpen:                         return "Open"
                case .FileOpenWorkspace:                return "Workspace..."
                case .FileOpenClearWorkspaceHistory:    return "Clear Recent Workspaces"
                case .FileCloseFile:                    return "Close File"
                case .FileCloseWorkspace:               return "Close Workspace"
                case .FileDelete:                       return "Delete"
                case .FileShowInFinder:                 return "Show in Finder"
                case .FileShowInTerminal:               return "Show in Terminal"
                case .View:                             return "View"
                case .ViewEditor:                       return "Editor"
                case .ViewShowNavigator:                return "Navigators"
                case .ViewShowProjectNavigator:         return "Show File Navigator"
                case .ViewShowIssueNavigator:           return "Show Issue Navigator"
                case .ViewShowDebugNavigator:           return "Show Debug Navigator"
                case .ViewHideNavigator:                return "Hide Navigator"
                case .ViewConsole:                      return "Logs"
                case .ViewFullScreen:                   return "Toggle Full Screen"
                case .Editor:                           return "Editor"
                case .EditorShowCompletions:            return "Show Completions"
                case .Product:                          return "Product"
                case .ProductRun:                       return "Run"
                case .ProductBuild:                     return "Build"
                case .ProductClean:                     return "Clean"
                case .ProductStop:                      return "Stop"
                case .Debug:                            return "Debug"
                case .DebugPause:                       return "Pause"
                case .DebugResume:                      return "Resume"
                case .DebugHalt:                        return "Halt"
                case .DebugStepInto:                    return "Step Into"
                case .DebugStepOut:                     return "Step Out"
                case .DebugStepOver:                    return "Step Over"
                case .DebugClearConsole:                return "Clear Console"
                }
        }
        func getKeyModifiersAndEquivalentPair() -> (keyModifier: NSEventModifierFlags, keyEquivalent: String) {
                let shortcut = getShortcutKey()
                return (shortcut?.keyModifiers ?? [], shortcut?.keyEquivalent ?? "")
        }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private extension Menu2Code {
        private func getShortcutKey() -> Menu2ShortcutKey? {
                let Command	=       NSEventModifierFlags.CommandKeyMask
                let Option	=       NSEventModifierFlags.AlternateKeyMask
                let Control     =       NSEventModifierFlags.ControlKeyMask
                let Shift       =       NSEventModifierFlags.ShiftKeyMask
                let Return      =       "\r"
                let Delete      =	"\u{0008}"
                let F6          =       String(UnicodeScalar(NSF6FunctionKey))
                let F7          =       String(UnicodeScalar(NSF7FunctionKey))
                let F8          =       String(UnicodeScalar(NSF8FunctionKey))

                switch self {
                case .Separator:                        return nil
                case .File:                             return nil
                case .FileNew:                          return nil
                case .FileNewWorkspace:			return Command + Control + "N"
                case .FileNewFolder:                    return Command + Option + "N"
                case .FileNewFile:                      return Command + "N"
                case .FileOpen:                         return nil
                case .FileOpenWorkspace:                return Command + "O"
                case .FileOpenClearWorkspaceHistory:    return nil
                case .FileCloseFile:                    return Command + Shift + "W"
                case .FileCloseWorkspace:               return Command + "W"
                case .FileDelete:                       return Command + Delete
                case .FileShowInFinder:                 return nil
                case .FileShowInTerminal:               return nil
                case .View:                             return nil
                case .ViewEditor:                       return Command + Return
                case .ViewShowNavigator:                return nil
                case .ViewShowProjectNavigator:         return Command + "1"
                case .ViewShowIssueNavigator:           return Command + "2"
                case .ViewShowDebugNavigator:           return Command + "3"
                case .ViewHideNavigator:                return Command + "0"
                case .ViewConsole:                      return Command + Shift + "C"
                case .ViewFullScreen:                   return Command + Control + "F"
                case .Editor:                           return nil
                case .EditorShowCompletions:            return Command + " "
                case .Product:                          return nil
                case .ProductRun:                       return Command + "R"
                case .ProductBuild:                     return Command + "B"
                case .ProductClean:                     return Command + Shift + "K"
                case .ProductStop:                      return Command + "."
                case .Debug:                            return nil
                case .DebugPause:                       return Command + Control + "Y"
                case .DebugResume:                      return Command + Control + "Y"
                case .DebugHalt:                        return nil
                case .DebugStepInto:                    return Command + F6
                case .DebugStepOut:                     return Command + F7
                case .DebugStepOver:                    return Command + F8
                case .DebugClearConsole:                return Command + "K"
                }
        }
}
private struct Menu2ShortcutKey {
        var keyModifiers: NSEventModifierFlags
        var keyEquivalent: String
}
private func + (a: NSEventModifierFlags, b: NSEventModifierFlags) -> Menu2ShortcutKey {
        return Menu2ShortcutKey(keyModifiers: [a, b], keyEquivalent: "")
}
private func + (a: NSEventModifierFlags, b: String) -> Menu2ShortcutKey {
        return Menu2ShortcutKey(keyModifiers: a, keyEquivalent: b.lowercaseString)
}
private func + (a: Menu2ShortcutKey, b: String) -> Menu2ShortcutKey {
        return Menu2ShortcutKey(keyModifiers: a.keyModifiers, keyEquivalent: a.keyEquivalent + b.lowercaseString)
}





