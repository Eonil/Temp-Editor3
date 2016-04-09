//
//  Document.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Cocoa

final class WorkspaceDocument: NSDocument {
	enum Error: ErrorType {
		case BadDocumentURL
	}

	////////////////////////////////////////////////////////////////

	override init() {
		super.init()
		Workspace.Event.Notification.register(self, self.dynamicType.process)
	}
	deinit {
		Workspace.Event.Notification.deregister(self)
	}

	////////////////////////////////////////////////////////////////

	weak var workspace: Workspace? {
		didSet {
			render()
		}
	}
	let workspaceWindowController = WorkspaceWindowController()

	////////////////////////////////////////////////////////////////

        override func makeWindowControllers() {
                debugLog("makeWindowControllers")
                super.makeWindowControllers()
                addWindowController(workspaceWindowController)
//                assert(workspace != nil)
//                workspaceWindowController.workspace = workspace
        }
        override class func autosavesInPlace() -> Bool {
                return true
        }
        override func dataOfType(typeName: String) throws -> NSData {
                // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
                // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
	override func readFromURL(url: NSURL, ofType typeName: String) throws {
		guard url.URLByDeletingLastPathComponent != nil else {
			throw Error.BadDocumentURL
		}
		render()
	}
//        override func readFromData(data: NSData, ofType typeName: String) throws {
//                // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
//                // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
//                // If you override either of these, you .should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
//                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//        }

	////////////////////////////////////////////////////////////////

	private func process(n: Workspace.Event.Notification) {
		guard n.sender ==== workspace else { return }
		render()
	}
	private func processDocumentDidMove(error: NSError?) {
		render()
	}

	////////////////////////////////////////////////////////////////

	private func render() {
		fileURL = workspace?.locationURL?.URLByAppendingPathComponent("Workspace.Editor3FileList")
		workspaceWindowController.workspace = workspace
//		if workspaceWindowController.window?.mainWindow == true {
//		}
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









