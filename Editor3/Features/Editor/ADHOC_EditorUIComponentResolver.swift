//
//  ADHOC_EditorUIComponentResolver.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/17.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Provides a way to query some UI components using context keys.
///
/// - Note:
///	Keep all methods flat rather than nested.
///	If yuo're going to resolve a nested UI components, 
///	you will need all context keys alone routes.
protocol ADHOC_EditorUIComponentResolver: class {
	func findWorkspaceDocumentForWorkspace(workspace: Workspace) -> WorkspaceDocument? 
}
extension ADHOC_EditorUIComponentResolver {
	func findWorkspaceDocumentForWorkspace(workspace: Workspace) -> WorkspaceDocument? {
		for document in NSDocumentController.sharedDocumentController().documents {
			guard let workspaceDocument = document as? WorkspaceDocument else { continue }
			guard workspaceDocument.workspace ==== workspace else { continue }
			return workspaceDocument
		}
		return nil
	}
}









