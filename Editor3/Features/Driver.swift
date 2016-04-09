//
//  Driver.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class Driver {

        // MARK: -
        static private(set) weak var theDriver: Driver?

        // MARK: -
        init() {
                mainMenuController = MainMenuController(editor: editor)
                editorUIController.editor = editor
                Driver.theDriver = self
                Editor.Event.Notification.register(self, self.dynamicType.process)
        }
        deinit {
                Editor.Event.Notification.deregister(self)
                Driver.theDriver = nil
		editorUIController.editor = nil
        }

        // MARK: -
        let editor = Editor()
	let editorUIController = EditorUIController()
        let mainMenuController: MainMenuController
        func test1() {
//                // Test.
//                let doc = WorkspaceDocument()
//                NSDocumentController.sharedDocumentController().addDocument(doc)
//                doc.makeWindowControllers()
//                doc.showWindows()
        }

        // MARK: -
        private func process(n: Editor.Event.Notification) {
                guard n.sender ==== editor else { return }
		switch n.event {
		case .DidChangeMainWorkspace:
			renderMainWorkspaceSelectionOnly()

		case .DidAddWorkspace(let workspace):
			renderWorkspaceDocumentsWithMutationEvents(.DidInsert(workspace))

		case .WillRemoveWorkspace(let workspace):
			renderWorkspaceDocumentsWithMutationEvents(.WillRemove(workspace))
		}
        }

        private func render() {
		renderMainWorkspaceSelectionOnly()
		let oldWorkspaces = NSDocumentController.sharedDocumentController().findAllWorkspaces().toObjectSet()
		let newWorkspaces = editor.workspaces
		let (insertions, removings) = newWorkspaces.differencesFrom(oldWorkspaces)
		for insertion in insertions {
			renderWorkspaceDocumentsWithMutationEvents(.DidInsert(insertion))
		}
		for removing in removings {
			renderWorkspaceDocumentsWithMutationEvents(.WillRemove(removing))
		}
        }
	private func renderMainWorkspaceSelectionOnly() {
		// Sync selection if needed.
		editor.mainWorkspace?.findDocument()?.workspaceWindowController.window?.makeMainWindow()
	}
	private func renderWorkspaceDocumentsWithMutationEvents(event: ObjectSetMutationEvent<Workspace>) {
		switch event {
		case .DidInsert(let workspace):
			if workspace.findDocument() == nil {
				// Open workspace document if needed and possible.
				guard let locationURL = workspace.locationURL else { break }
				let u1 = locationURL.URLByAppendingPathComponent("Workspace.Editor3FileList")
				NSDocumentController.sharedDocumentController()
					.openDocumentWithContentsOfURL(u1, display: true, completionHandler: { [weak self] (newDocument: NSDocument?, _: Bool, error: NSError?) in
						guard let newWorkspaceDocument = newDocument as? WorkspaceDocument else {
							if let error = error {
								reportToDevelopers(error)
								NSApplication.sharedApplication().presentError(error)
							}
							return
						}
						newWorkspaceDocument.workspace = workspace
						for _ in 0...0 {
							guard let editor = self?.editor else { continue }
							if newWorkspaceDocument.workspaceWindowController.window?.mainWindow == true {
								editor.mainWorkspace = workspace
							}
						}
				})
			}

		case .WillRemove(let workspace):
			// Close workspace document if needed.
			if let document = workspace.findDocument() {
				document.workspace = nil
				document.close()
			}
		}
	}
}

private extension Workspace {
	func findDocument() -> WorkspaceDocument? {
		for document in NSDocumentController.sharedDocumentController().documents {
			guard let document = document as? WorkspaceDocument else { continue }
			return document
		}
		return nil
	}
}

private extension NSDocumentController {
	func findAllWorkspaces() -> [Workspace] {
		var workspaces = [Workspace]()
		for document in documents {
			guard let workspaceDocument = document as? WorkspaceDocument else { continue }
			guard let workspace = workspaceDocument.workspace else { continue }
			workspaces.append(workspace)
		}
		return workspaces
	}
}
private extension Array where Element: AnyObject {
	func toObjectSet() -> ObjectSet<Element> {
		var set = ObjectSet<Element>()
		for element in self {
			set.insert(element)
		}
		return set
	}
}















