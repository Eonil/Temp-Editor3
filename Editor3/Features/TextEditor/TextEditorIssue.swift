//
//  TextEditorIssue.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

enum TextEditorIssue {
	case CannotSetEditingFileURLTo(NSURL?, dueToError: ErrorType)
}