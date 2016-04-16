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
}
extension EditorCommonUIPresentableErrorType {
	func toUIPresentableError() -> NSError {
		let Editor3ErrorDomain = "Editor3UIErrorDomain"
		return NSError(domain: Editor3ErrorDomain, code: -1, userInfo: [
			NSLocalizedDescriptionKey: localizedDescriptionForUI(),
			])
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension NSError: EditorCommonUIPresentableErrorType {
	func toUIPresentableError() -> NSError {
		return self
	}
	func localizedDescriptionForUI() -> String {
		return localizedDescription
	}
}
