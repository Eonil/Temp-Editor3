//
//  FileNavigatorIssue.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

enum FileNavigatorIssue {
	case CannotReadWorkspaceFileListFileFromURL(location: NSURL)
	case CannotDecodeWorkspaceFileListFileAsUTF8(data: NSData)
	case CannotParseWorkspaceFileListFile(snapshot: String, dueToError: ErrorType)
}
