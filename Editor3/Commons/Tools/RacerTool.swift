//
//  RacerTool.swift
//  EditorModel
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class RacerTool {

        // MARK: -
        func queryWithFullyQualifiedName(namePart: String) -> [RacerMatch] {
		let shell = ShellTaskExecutionController()
		shell.launch(workingDirectoryPath: "/")
		shell.standardInput.writeUTF8String("export RUST_SRC_PATH=\"$HOME/Temp/rustc-1.7.0/src\"\n")
		shell.standardInput.writeUTF8String("racer complete \(namePart)\n")
		shell.standardInput.writeUTF8String("exit\n")
		let output = shell.standardOutput.readUTF8StringToEndOfFile()
		let lines = output.componentsSeparatedByString("\n")
		enum Error: ErrorType {
			case BadOutputForm
			case ImparsableLineExpression
			case ImparsableColumnExpression
			case UnknownMatchType
		}
		func lineToMatch(line: String) throws -> RacerMatch {
			let parts = line.componentsSeparatedByString("\t")
			if parts.count != 6 {
				throw Error.BadOutputForm
			}
			let code = parts[0]
			guard let line = Int(parts[1]) else { throw Error.ImparsableLineExpression }
			guard let column = Int(parts[2]) else { throw Error.ImparsableColumnExpression }
			let path = parts[3]
			guard let type = RacerMatchType(rawValue: parts[4]) else { throw Error.UnknownMatchType }
			let context = parts[5]
			return RacerMatch(
				code: code,
				lineNumber: line,
				columnNumber: column,
				filePath: path,
				type: type,
				context: context)
		}
		do {
			let matches = try lines.map(lineToMatch)
			return matches
		}
		catch let error {
			debugLog(error)
			return []
		}
        }
	/// - Parameter lineNumber	1-based line index.
	/// - Parameter characterNumber	0-based BYTE index in UTF-8 encoded string byte array.
        func queryWithLineNumber(lineNumber: Int, characterNumber: Int, filePath: String) -> [RacerMatch] {
		let shell = ShellTaskExecutionController()
		shell.launch(workingDirectoryPath: "/")
		shell.standardInput.writeUTF8String("export RUST_SRC_PATH=\"$HOME/Temp/rustc-1.7.0/src\"\n")
		shell.standardInput.writeUTF8String("racer --interface tab-text complete \(lineNumber) \(characterNumber) \(filePath)\n")
		shell.standardInput.writeUTF8String("exit\n")
		let output = shell.standardOutput.readUTF8StringToEndOfFile()
		let lines = output.componentsSeparatedByString("\n")
		var outputParser = RacerOutputParser()
		do {
			for line in lines {
				guard line != "" else { continue }
				try outputParser.pushLine(line)
			}
		}
		catch let error {
			reportToDevelopers("\(error)")
			return []
		}
		assert(outputParser.isEnded)
		shell.waitUntilExit()
		return outputParser.matches
        }
}


























