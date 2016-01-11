//
//  CargoIssue.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

enum CargoIssue {
	case UnparsableMessage(String)
	case RustCompileIssue(CargoRustCompilationIssue)

	init(code: String) {
		self = parseLine(code)
	}
}

struct CargoRustCompilationIssue {
	var severity: CargoRustCompilationIssueSeverity
	var path: String
	var start: CargoRustCompilationIssueSourceCodePoint
	var end: CargoRustCompilationIssueSourceCodePoint
	var message: String
}
struct CargoRustCompilationIssueSourceCodePoint {
	/// 0-based.
	var line: Int
	/// 0-based.
	var column: Int
}

enum CargoRustCompilationIssueSeverity: String {
	case Note	=	"note"
	case Error	=	"error"
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
private func parseLine(line: String) -> CargoIssue {
	var parts = [String]()
	var part = ""
	for ch in line.characters {
		if ch != ":" || parts.count > 5 {
			part.append(ch)
		}
		else {
			parts.append(part)
			part = ""
		}
	}
	let charset = NSCharacterSet.whitespaceAndNewlineCharacterSet()
	parts = parts.map { $0.stringByTrimmingCharactersInSet(charset) }

	guard parts.count == 6 else { return CargoIssue.UnparsableMessage(line) }
	let filePath = parts[0]
	guard let startLine = Int(parts[1]) else { return CargoIssue.UnparsableMessage(line) }
	guard let startCol = Int(parts[2]) else { return CargoIssue.UnparsableMessage(line) }
	let start = CargoRustCompilationIssueSourceCodePoint(line: startLine, column: startCol)
	guard let endLine = Int(parts[3]) else { return CargoIssue.UnparsableMessage(line) }
	let endColAndSeverity = parts[4]
	let endColAndSeverityParts = endColAndSeverity.componentsSeparatedByString(" ")
	guard endColAndSeverityParts.count == 2 else { return CargoIssue.UnparsableMessage(line) }
	guard let endCol = Int(endColAndSeverityParts[0]) else { return CargoIssue.UnparsableMessage(line) }
	let end = CargoRustCompilationIssueSourceCodePoint(line: endLine, column: endCol)
	guard let severity = CargoRustCompilationIssueSeverity(rawValue: endColAndSeverityParts[1]) else { return CargoIssue.UnparsableMessage(line) }
	let message = parts[5]
	let rustcIssue = CargoRustCompilationIssue(
		severity: severity,
		path: filePath,
		start: start,
		end: end,
		message: message)
	return CargoIssue.RustCompileIssue(rustcIssue)
}
