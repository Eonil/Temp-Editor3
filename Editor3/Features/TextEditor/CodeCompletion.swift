//
//  CodeCompletion.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

//struct CodeCompletion {
//        var candidates: [String]
//}
//
//struct CodeCandidate {
//        var expression: String
//}

final class CodeCompletion {
        private(set) var candidates = [CodeCompletionCandidate]() {
                didSet {
			Event.Notification(sender: self, event: .DidChangeCandidates).broadcast()
                }
        }

//	/// Runs asynchronously
//	/// Errors will be fired as notifications.
//	func runReloadingForFileURL(fileURL: NSURL, line: Int, column: Int) {
//
//	}

	func removeAllCandidates() {
		candidates.removeAll()
	}
	/// - Parameter line:	0-based index.
	/// - Parameter bytes:	0-based index.
	func reloadForFileURL(fileURL: NSURL, point: TextEditorCharacterSelectionPoint) {
		removeAllCandidates()
		assert(fileURL.fileURL)
		assert(fileURL.path != nil)
		guard let path = fileURL.path else { fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() }
		let racer = RacerTool()
		let line = point.line + 1
		let bytes = point.bytes + 0
		let matches = racer.queryWithLineNumber(line, characterNumber: bytes, filePath: path)
		func matchToCandidate(match: RacerMatch) -> CodeCompletionCandidate {
			return CodeCompletionCandidate(signature: match.stringify(), comment: nil)
		}
		candidates = matches.map(matchToCandidate)
	}
}
extension CodeCompletion {
//	enum Error: ErrorType {
//		case ErrorInRunningRacerTool
//	}
        enum Event {
                typealias Notification = EventNotification<CodeCompletion,Event>
                case DidChangeCandidates
//		case Error(CodeCompletion.Error)
        }
}

struct CodeCompletionCandidate {
        var signature: String
        var comment: String?
}

//struct CodeCompletionSignature {
//        var name: String
//        var arugments: [(name: String, type: String)]
//        var returning: String
//}






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private extension RacerMatch {
	func stringify() -> String {
		return "\(code) \(type) \(context)"
	}
}
