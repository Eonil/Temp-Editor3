//
//  RacerMatch.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct RacerMatch {
	var code: String
	var lineNumber: Int
	var columnNumber: Int
	var filePath: String
	var type: RacerMatchType // `mtype`
	var context: String
}
enum RacerMatchType: String {
	case Struct
	case Module
	case MatchArm
	case Function
	case Crate
	case Let
	case IfLet
	case WhileLet
	case For
	case StructField
	case Impl
	case Enum
	case EnumVariant
	case Type
	case FnArg
	case Trait
	case Const
	case Static
}




