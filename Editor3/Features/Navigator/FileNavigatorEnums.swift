//
//  FileNavigatorEnums.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/16.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

let FileNavigationNewNameTrialMaxCount		=	Int(1024)

enum FileNavigatorError: ErrorType {
	case CannotResolvePathOfNodeAtPath(WorkspaceItemPath)
	case CannotCreateNewFile(reason: EditorCommonUIPresentableErrorType)
	case CannotCreateNewFolder(reason: EditorCommonUIPresentableErrorType)
	case CannotCopyFile(from: NSURL, to: NSURL, reason: EditorCommonUIPresentableErrorType?)
}
struct FileNavigatorMultipleErrors: ErrorType {
	var errors: [FileNavigatorError]
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension FileNavigatorMultipleErrors: EditorCommonUIPresentableErrorType {
	func localizedDescriptionForUI() -> String {
		if errors.count == 1 {
			return errors[0].localizedDescriptionForUI()
		}
		return "Cannot complete file operations. Multiple errors are occured."
	}
}
extension FileNavigatorError: EditorCommonUIPresentableErrorType {
	func localizedDescriptionForUI() -> String {
		switch self {
		case .CannotCopyFile(let from, let to, let reason):
			return reason?.localizedDescriptionForUI() ?? "Cannot copy file from \"\(from)\" to \"\(to)\"."

		case .CannotResolvePathOfNodeAtPath(let path):
			return "Cannot resolve path of a file node \"\(path)\"."

		case .CannotCreateNewFolder(let reason):
			return reason.localizedDescriptionForUI()
//			return reason.localizedDescriptionForUI() ?? "Cannot create folder \"\(url.lastPathComponent)\"."

		case .CannotCreateNewFile(let reason):
			return reason.localizedDescriptionForUI()
		}
	}
}


























