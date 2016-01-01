//
//  NotificationUtility.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct NotificationUtility {
        static func register(identity: AnyObject, _ notificationNames: [String], _ handler: NSNotification->()) {
                for name in notificationNames {
                        register(identity, name, handler)
                }
        }
        static func register(identity: AnyObject, _ notificationName: String, _ handler: NSNotification->()) {
                let id = ObjectIdentifier(identity)
		let handle = NSNotificationCenter.defaultCenter().addObserverForName(notificationName,
                        object: nil,
                        queue: NSOperationQueue.mainQueue()) {
                                handler($0)
                }
                mapping[id]?.append(handle)
        }
        static func deregister(identity: AnyObject) {
                let id = ObjectIdentifier(identity)
                if let handles = mapping.removeValueForKey(id) {
                        for handle in handles {
                                NSNotificationCenter.defaultCenter().removeObserver(handle)
                        }
                }
        }
        static var mapping = [ObjectIdentifier: [AnyObject]]()
}
