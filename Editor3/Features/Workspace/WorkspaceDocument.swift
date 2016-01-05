//
//  Document.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Cocoa

final class WorkspaceDocument: NSDocument {

        override init() {
                super.init()
                guard let driver = Driver.theDriver else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                let newWorkspace = Workspace(ownerDocument: self)
                driver.editor.addWorkspace(newWorkspace, forDocument: self)
                self.workspace = newWorkspace
		
		assert(workspace != nil)
		guard let workspace = workspace else { return }
		workspace.reloadFileTree()
        }
        deinit {
                guard let driver = Driver.theDriver else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
                guard let workspace = workspace else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers("Workspace should not be dead before related WorkspaceDocument object dies.") }
                driver.editor.removeWorkspace(workspace, forDocument: self)
        }

        private(set) weak var workspace: Workspace?
	let workspaceWindowController = WorkspaceWindowController()

        override func makeWindowControllers() {
                debugLog("makeWindowControllers")
                super.makeWindowControllers()
                addWindowController(workspaceWindowController)
                assert(workspace != nil)
                workspaceWindowController.workspace = workspace
        }

        override class func autosavesInPlace() -> Bool {
                return true
        }

        override func dataOfType(typeName: String) throws -> NSData {
                // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
                // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }

        override func readFromData(data: NSData, ofType typeName: String) throws {
                // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
                // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
                // If you override either of these, you .should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
}
private extension WorkspaceDocument {
	func processDocumentDidMove(error: NSError?) {
		checkAndReportFailureToDevelopers(workspace != nil)
		if let workspace = workspace {
			workspace.reloadFileTree()
		}
	}
}
extension WorkspaceDocument {
	override func moveToURL(url: NSURL, completionHandler: ((NSError?) -> Void)?) {
		super.moveToURL(url) { [weak self] error in
			self?.processDocumentDidMove(error)
			completionHandler?(error)
		}
	}
}









