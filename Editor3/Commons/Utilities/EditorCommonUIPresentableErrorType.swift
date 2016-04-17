//
//  EditorCommonUIPresentableErrorType.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/17.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

protocol EditorCommonUIPresentableErrorType: ErrorType {
	func toUIPresentableError() -> NSError
	func localizedDescriptionForUI() -> String
	func getUnderlyingErrors() -> [EditorCommonUIPresentableErrorType]
}
extension EditorCommonUIPresentableErrorType {
	func toUIPresentableError() -> NSError {
		let Editor3ErrorDomain = "Editor3UIErrorDomain"
		return NSError(domain: Editor3ErrorDomain, code: -1, userInfo: [
			NSLocalizedDescriptionKey: localizedDescriptionForUI(),
			])
	}
	func getUnderlyingErrors() -> [EditorCommonUIPresentableErrorType] {
		return []
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct EditorCommonMultipleErrors: ErrorType {
	var errors: [EditorCommonUIPresentableErrorType]
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension String: EditorCommonUIPresentableErrorType {
	func localizedDescriptionForUI() -> String {
		return self
	}
}
extension NSError: EditorCommonUIPresentableErrorType {
	func toUIPresentableError() -> NSError {
		return self
	}
	func localizedDescriptionForUI() -> String {
		return localizedDescription
	}
}
extension EditorCommonMultipleErrors: EditorCommonUIPresentableErrorType {
	func localizedDescriptionForUI() -> String {
		return "Multiple errors are occured."
	}
	func getUnderlyingErrors() -> [EditorCommonUIPresentableErrorType] {
		return errors
	}
}


