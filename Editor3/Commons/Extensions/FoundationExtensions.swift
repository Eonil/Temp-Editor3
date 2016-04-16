//
//  FoundationExtensions.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

enum NSURLExistence {
	case None
	case Data
	case Directory
}

extension NSURL {
	func getExistence() throws -> NSURLExistence {
		if try isExistingAsDirectoryFile() == true { return .Directory }
		if try isExistingAsDataFile() == true { return .Data }
		return .None
	}
}
public extension NSURL {
        public var displayName:String {
                get {
                        return	NSFileManager.defaultManager().displayNameAtPath(path!)
                }
        }

        public func isExistingAsAnyFile() -> Bool {
                var	err	=	nil as NSError?
                let	ok	=	self.checkResourceIsReachableAndReturnError(&err)
                assert(ok == true || err != nil)
                if !ok {
                        debugLog("existingAsAnyFile: \(err)")
                }
                return	ok
	}
	public func isExistingAsDataFile() throws -> Bool {
		if isExistingAsAnyFile() {
			var	dir: AnyObject?	=	false as AnyObject?
			try self.getResourceValue(&dir, forKey: NSURLIsDirectoryKey)
			return	dir as! Bool == false
		}
		return	false
	}
        public func isExistingAsDirectoryFile() throws -> Bool {
                if isExistingAsAnyFile() {
                        var dir: AnyObject? = false as AnyObject?
                        try self.getResourceValue(&dir, forKey: NSURLIsDirectoryKey)
                        return dir as! Bool == true
                }
                return	false
        }
}

extension NSFileHandle {
        func writeUTF8String(s:String) {
                let	d1	=	s.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                self.writeData(d1)
        }
        func readUTF8StringToEndOfFile() -> String {
                let	d1	=	self.readDataToEndOfFile()
                let	s1	=	NSString(data: d1, encoding: NSUTF8StringEncoding)!
                return	s1 as String
        }
}

extension String {
	func attributed() -> NSAttributedString {
		return NSAttributedString(string: self)
	}
}
extension NSString {
	func attributed() -> NSAttributedString {
		return (self as String).attributed()
	}
}
extension NSAttributedString {
	func fonted(font: NSFont) -> NSAttributedString {
		return attributed([
			NSFontAttributeName: font,
		])
	}
	func colored(color: NSColor) -> NSAttributedString {
		return attributed([
			NSForegroundColorAttributeName: color,
		])
	}
	private func attributed(attributes: [String: AnyObject]) -> NSAttributedString {
		let newAttributedString = NSMutableAttributedString(attributedString: self)
		let wholeRange = NSRange(location: 0, length: length)
		newAttributedString.addAttributes(attributes, range: wholeRange)
		return NSAttributedString(attributedString: newAttributedString)
	}
}












