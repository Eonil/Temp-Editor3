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
// Owner protocols provides identity of owner and read-only informations about owners.
// These do not provide any mutators.
//
// You cannot query model subnode through owner node protocol.
// You cannot mutate existing data field through owner node protocol.
// Owner node protocol may provide some read-only data fields of owner node.
// 
// Owner node protocols are not intended to be used to query every node of the model graph.
// It is provided only to identify some informations and very limited data set.
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























