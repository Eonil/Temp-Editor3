//
//  Editor.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class Editor {
        enum Event {
                typealias Notification = EventNotification<Editor,Event>
                case DidChangeMainWorkspace
		case DidAddWorkspace(Workspace)
		case WillRemoveWorkspace(Workspace)
        }

        // MARK: -
    
        /// A `Workspace` that is connected to main window.
	weak var mainWorkspace: Workspace? {
                didSet {
                        guard mainWorkspace !=== oldValue else { return }
			debugLog("main workspace = \(mainWorkspace?.locationURL)")
                        Event.Notification(sender: self, event: .DidChangeMainWorkspace).broadcast()
                }
        }
        private(set) var workspaces = ObjectSet<Workspace>()

        func addWorkspace(workspace: Workspace) {
		workspaces.insert(workspace)
		Event.Notification(sender: self, event: .DidAddWorkspace(workspace)).broadcast()
        }

        func removeWorkspace(workspace: Workspace) {
                if workspace === mainWorkspace {
                        mainWorkspace = nil
		}
		Event.Notification(sender: self, event: .WillRemoveWorkspace(workspace)).broadcast()
		workspaces.remove(workspace)
        }
}
extension Editor {
}
















