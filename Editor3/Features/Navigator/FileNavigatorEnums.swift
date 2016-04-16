//
//  FileNavigatorEnums.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/16.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

enum FileNavigatorError: ErrorType {
	case ErrorsInPerformingMultipleFileOperations(errors: [FileNavigatorFileOperationError])
}
enum FileNavigatorFileOperationError: ErrorType {
	case CannotResolvePathOfNodeAtPath(WorkspaceItemPath)
	case CannotCreateFolderAtURL(NSURL, reason: EditorCommonUIPresentableErrorType?)
	case CannotCopyFile(from: NSURL, to: NSURL, reason: EditorCommonUIPresentableErrorType?)
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension FileNavigatorError: EditorCommonUIPresentableErrorType {
	func localizedDescriptionForUI() -> String {
		switch self {
		case .ErrorsInPerformingMultipleFileOperations(let errors):
			if errors.count == 1 {
				return errors[0].localizedDescriptionForUI()
			}
			return "Cannot complete file operations. Multiple errors are occured."
		}
	}
}
extension FileNavigatorFileOperationError: EditorCommonUIPresentableErrorType {
	func localizedDescriptionForUI() -> String {
		switch self {
		case .CannotCopyFile(let from, let to, let reason):
			return reason?.localizedDescriptionForUI() ?? "Cannot copy file from \"\(from)\" to \"\(to)\"."

		case .CannotResolvePathOfNodeAtPath(let path):
			return "Cannot resolve path of a file node \"\(path)\"."

		case .CannotCreateFolderAtURL(let url, let reason):
			return reason?.localizedDescriptionForUI() ?? "Cannot create folder \"\(url.lastPathComponent)\"."
		}
	}
}


























