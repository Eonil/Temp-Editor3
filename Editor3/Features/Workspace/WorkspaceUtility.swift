//
//  WorkspaceUtility.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/16.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct WorkspaceUtility {
	static func resolvePathInWorkspace(workspace: OwnerWorkspace, ofURL: NSURL) -> WorkspaceItemPath? {
		guard let workspaceLocationURL = workspace.locationURL else { return nil }
		var u = ofURL
		var parts = [String]()
		while let u1 = u.URLByDeletingPathExtension {
			guard let p = u.lastPathComponent else { break }
			guard u1 != u else { break }
			parts.insert(p, atIndex: 0)
			if workspaceLocationURL == u1 {
				return WorkspaceItemPath(parts: parts)
			}
			u = u1
		}
		// Deleted all parts of the URL.
		// Which means the URL is not a part of the workspace.
		return nil
	}
}

extension NSURL {
	func toRelativeItemPathInWorkspace(workspace: OwnerWorkspace) -> WorkspaceItemPath? {
		return WorkspaceUtility.resolvePathInWorkspace(workspace, ofURL: self)
	}
}