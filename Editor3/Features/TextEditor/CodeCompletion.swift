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
//	enum Error: ErrorType {
//		case ErrorInRunningRacerTool
//	}
        enum Event {
                typealias Notification = EventNotification<CodeCompletion,Event>
		case DidChangeSelectionIndex
		case DidChangeAllCandidates
		case DidChangeFilteredCandidates
        }

	var selectedCandidateIndex: Int? {
		didSet {
			guard selectedCandidateIndex != oldValue else { return }
			Event.Notification(sender: self, event: .DidChangeSelectionIndex).broadcast()
		}
	}
        private var allCandidates = [CodeCompletionCandidate]() {
                didSet {
			Event.Notification(sender: self, event: .DidChangeAllCandidates).broadcast()
			renderFilteredCandidates()
                }
        }
	private(set) var filteredCandidates = [CodeCompletionCandidate]() {
		didSet {
			Event.Notification(sender: self, event: .DidChangeFilteredCandidates).broadcast()
		}
	}

	var searchExpression: String = "" {
		didSet {
			guard searchExpression != oldValue else { return }
			renderFilteredCandidates()
		}
	}

//	/// Runs asynchronously
//	/// Errors will be fired as notifications.
//	func runReloadingForFileURL(fileURL: NSURL, line: Int, column: Int) {
//
//	}
	func removeAllCandidates() {
		allCandidates.removeAll()
	}
	func moveUpSelection() {
		guard filteredCandidates.count > 0 else { return }
		func getNewIndex() -> Int {
			guard let oldIndex = selectedCandidateIndex else { return filteredCandidates.startIndex }
			let minAllowedIndex = filteredCandidates.startIndex + 0
			guard oldIndex > minAllowedIndex else { return minAllowedIndex }
			return oldIndex - 1
		}
		selectedCandidateIndex = getNewIndex()
	}
	func moveDownSelection() {
		guard filteredCandidates.count > 0 else { return }
		func getNewIndex() -> Int {
			guard let oldIndex = selectedCandidateIndex else { return filteredCandidates.startIndex }
			let maxAllowedIndex = filteredCandidates.endIndex - 1
			guard oldIndex < maxAllowedIndex else { return maxAllowedIndex }
			return oldIndex + 1
		}
		selectedCandidateIndex = getNewIndex()
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
		allCandidates = matches.map(matchToCandidate)
	}

	private func renderFilteredCandidates() {
		if searchExpression == "" {
			filteredCandidates = allCandidates
		}
		else {
			filteredCandidates = allCandidates.filter({ $0.signature.hasPrefix(searchExpression) })
		}
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
