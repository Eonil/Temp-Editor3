//
//  WorkspaceItemPAth.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

/// An absolute path from workspace root.
///
struct WorkspaceItemPath {

        static let	root	=	WorkspaceItemPath(parts: [])

        init(parts: [String]) {
                assert(parts.filter({ $0 == "" }).count == 0, "Empty string cannot be a name part.")
                assert(parts.map(WorkspaceItemPath._isPartValid).reduce(true, combine: { $0 && $1 }))

                _parts	=	parts
        }

        ///

        var parts: [String] {
                get {
                        return	_parts
                }
        }

        func pathByAppendingLastComponent(part: String) -> WorkspaceItemPath {
		return lastPartAppended(part)
        }
        func pathByDeletingFirstComponent() -> WorkspaceItemPath {
		return firstPartDeleted()
        }
        func pathByDeletingLastComponent() -> WorkspaceItemPath {
		return lastPartDeleted()
        }
        func hasPrefix(prefixPath: WorkspaceItemPath) -> Bool {
                guard prefixPath.parts.count <= _parts.count else {
                        return	false
                }
                for i in 0..<prefixPath.parts.count {
                        guard parts[i] == prefixPath.parts[i] else {
                                return	false
                        }
                }
                return	true
        }

        ///

        private enum _PartError: ErrorType {
                /// A part is empty.
                case PartIsEmpty
                /// A path part cannot contain any slash character (`/`) that is reserved for part separator.
                case PartContainsSlash
        }
        
        private var	_parts	=	[String]()
        
        private static func _isPartValid(part: String) -> Bool {
                do {
                        try _validatePart(part)
                        return	true
                }
                catch {
                        return	false
                }
        }
        private static func _validatePart(part: String) throws {
                guard part != "" else {
                        throw	_PartError.PartIsEmpty
                }
                guard part.containsString("/") == false else {
                        throw	_PartError.PartContainsSlash
                }
        }
}
extension WorkspaceItemPath {
	var firstPart: String? {
		get {
			return parts.first
		}
	}
	var lastPart: String? {
		get {
			return parts.last
		}
	}
	func firstPartDeleted() -> WorkspaceItemPath {
		precondition(parts.count > 0)
		return	WorkspaceItemPath(parts: Array(parts[parts.startIndex.successor()..<parts.endIndex]))
	}
	func lastPartDeleted() -> WorkspaceItemPath {
		precondition(parts.count > 0)
		return	WorkspaceItemPath(parts: Array(parts[parts.startIndex..<parts.endIndex.predecessor()]))
	}
	func lastPartAppended(part: String) -> WorkspaceItemPath {
		assert(WorkspaceItemPath._isPartValid(part))
		preconditionAndReportFailureToDevelopers(WorkspaceItemPath._isPartValid(part))
		return	WorkspaceItemPath(parts: parts + [part])
	}
}












////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extension WorkspaceItemPath {
        /// - Returns:	
        ///	`nil` if workspace has no locaiton.
        ///	A proper file NSURL if workspace has a location.
        ///	This method does not perform file existence check, and just build
        ///	a URL.
        func absoluteFileURLForWorkspace(workspace: OwnerWorkspace) -> NSURL? {
                assert(workspace.locationURL != nil)
                assert(workspace.locationURL!.fileURL == true)
                guard let url = workspace.locationURL else { return nil }
                var url1 = url
                for p in _parts {
                        url1 = url1.URLByAppendingPathComponent(p)
                }
                return url1
        }
}

extension WorkspaceItemPath: CustomStringConvertible {
        var description: String {
                get {
                        return	"(WorkspaceItemPath: \(_parts))"
                }
        }
}
extension WorkspaceItemPath: Equatable, Hashable {
        var hashValue: Int {
                get {
                        return	parts.last?.hashValue ?? 0
                }
        }
}
func == (a: WorkspaceItemPath, b: WorkspaceItemPath) -> Bool {
        return	a.parts == b.parts
}




struct WorkspaceItemPathError: ErrorType {
        let	message	:	String
}











