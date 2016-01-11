//
//  IssueTypes.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/11.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

// MARK: -
enum IssueSeverity {
	/// Non-error message.
	/// Usually doesn't appear, but sometimes does.
	case Information
	/// An unrecoverable issue.
	case Error
	/// A recoverable issue.
	case Warning
}
protocol IssueType {
	var severity: IssueSeverity { get }
	var message: String { get }
}
