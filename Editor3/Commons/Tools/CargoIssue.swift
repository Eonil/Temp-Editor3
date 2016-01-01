//
//  CargoIssue.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

struct CargoIssue {
	var severity: CargoIssueSeverity
	var path: String
	/// 0-based.
	var line: Int
	/// 0-based.
	var column: Int
	var message: String
}

enum CargoIssueSeverity {
	case Warning
	case Error
}