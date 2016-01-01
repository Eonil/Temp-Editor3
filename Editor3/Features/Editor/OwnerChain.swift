//
//  OwnerChain.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Owner protocols provies identity of owner and read-only informations about owners.
// These do not provide any mutators.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

protocol OwnerEditor: class {

}
//protocol OwnerDocument: class {
//	var fileURL: NSURL? { get }
//}
protocol OwnerWorkspace: class {
        weak var ownerEditor: OwnerEditor? { get }
	var locationURL: NSURL? { get }
}
protocol OwnerTextEditor: class {
        weak var ownerWorkspace: OwnerWorkspace? { get }
}
protocol OwnerfileNavigator: class {
        weak var ownerWorkspace: OwnerWorkspace? { get }
}
protocol OwnerBuilder: class {
        weak var ownerWorkspace: OwnerWorkspace? { get }
}
protocol OwnerDebugger: class {
        weak var ownerWorkspace: OwnerWorkspace? { get }
}




