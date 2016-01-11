//
//  IssueTypeImplementations.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/11.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

extension Issue: IssueType {
	var severity: IssueSeverity {
		get {
			switch self {
			case .BuildIssue(let buildIssue):		return buildIssue.severity
			}
		}
	}
	var message: String {
		get {
			switch self {
			case .BuildIssue(let buildIssue):		return buildIssue.message
			}
		}
	}
}

extension BuildIssue: IssueType {
	var severity: IssueSeverity {
		get {
			switch self {
			case .CannotRunCargoDueToError:			return .Error
			case .CargoIssue(let cargoIssue):		return cargoIssue.severity
			}
		}
	}
	var message: String {
		get {
			switch self {
			case .CannotRunCargoDueToError(let error):	return "\(error)"
			case .CargoIssue(let cargoIssue):		return cargoIssue.message
			}
		}
	}
}

extension CargoIssue: IssueType {
	var severity: IssueSeverity {
		get {
			switch self {
			case .UnparsableMessage:
				return .Error
				
			case .RustCompileIssue(let cargoRustCompileIssue):
				switch cargoRustCompileIssue.severity {
				case .Note:	return .Warning
				case .Error:	return .Error
				}
			}
		}
	}
	var message: String {
		get {
			switch self {
			case .UnparsableMessage(let unparsableMessage):
				return unparsableMessage
			case .RustCompileIssue(let cargoRustCompilationIssue):
				return "\(cargoRustCompilationIssue.path) [\(cargoRustCompilationIssue.start.line):\(cargoRustCompilationIssue.start.column) ~ \(cargoRustCompilationIssue.end.line):\(cargoRustCompilationIssue.end.column)] \(cargoRustCompilationIssue.message)"
//				return cargoRustCompilationIssue.message
			}
		}
	}
}













