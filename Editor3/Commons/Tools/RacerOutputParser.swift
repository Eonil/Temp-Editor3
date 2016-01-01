//
//  RacerOutputParser.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct RacerOutputParser {
	var prefix: (start: Int, end: Int, code: String)?
	var matches: [RacerMatch] = []
	var isEnded: Bool = false

	mutating func pushLine(line: String) throws {
		assert(isEnded == false)
		preconditionAndReportFailureToDevelopers(isEnded == false)
		let result = try RacerOutputParser.parseLine(line)
		switch result {
		case .Prefix(let newPrefix):
			prefix = newPrefix
		case .Match(let newMatch):
			preconditionAndReportFailureToDevelopers(prefix != nil)
			matches.append(newMatch)
		case .End:
			isEnded = true
		}
	}
}
extension RacerOutputParser {
	enum Error: ErrorType {
		case UnexpectedOutputPrefix(line: String)
		case BadOutputForm
		case BadExpressionAsInt
		case UnknownMatchType
	}
	enum ParsingResult {
		/// - Parameter code:
		///	Prefix code part used to query matches.
		case Prefix(start: Int, end: Int, code: String)
		case Match(RacerMatch)
		case End
	}
}
extension RacerOutputParser {
	static func parseLine(line: String) throws -> ParsingResult {
		if line.hasPrefix("PREFIX") { return try .Prefix(parseLineAsPrefix(line)) }
		if line.hasPrefix("MATCH") { return try .Match(parseLineAsMatch(line)) }
		if line.hasPrefix("END") { return .End }
		throw Error.UnexpectedOutputPrefix(line: line)
	}
	private static func parseLineAsPrefix(line: String) throws -> (start: Int, end: Int, code: String) {
		let parts = line.componentsSeparatedByString("\t")
		guard parts.count == 4 else { throw Error.BadOutputForm }
		assert(parts[0] == "PREFIX")
		guard let start = Int(parts[1]) else { throw Error.BadExpressionAsInt }
		guard let end = Int(parts[2]) else { throw Error.BadExpressionAsInt }
		let code = parts[3]
		return (start, end, code)
	}
	private static func parseLineAsMatch(line: String) throws -> RacerMatch {
		let parts = line.componentsSeparatedByString("\t")
		guard parts.count == 7 else { throw Error.BadOutputForm }
		assert(parts[0] == "MATCH")
		let code = parts[1]
		guard let line = Int(parts[2]) else { throw Error.BadExpressionAsInt }
		guard let column = Int(parts[3]) else { throw Error.BadExpressionAsInt }
		let path = parts[4]
		guard let type = RacerMatchType(rawValue: parts[5]) else { throw Error.UnknownMatchType }
		let context = parts[6]
		return RacerMatch(
			code: code,
			lineNumber: line,
			columnNumber: column,
			filePath: path,
			type: type,
			context: context)
	}
}