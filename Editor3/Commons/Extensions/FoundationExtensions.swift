//
//  FoundationExtensions.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

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
                        var	dir: AnyObject?	=	false as AnyObject?
                        try self.getResourceValue(&dir, forKey: NSURLIsDirectoryKey)
                        return	dir as! Bool == true
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














