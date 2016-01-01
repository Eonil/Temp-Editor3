//
//  Reporting.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

func checkAndReportFailureToDevelopers(condition: Bool) {
        if condition == false {
                reportToDevelopers("check failure")
        }
        assert(condition)
}
func preconditionAndReportFailureToDevelopers(condition: Bool) {
        if condition == false {
                reportToDevelopers("precondition failure")
        }
	precondition(condition)
}

@noreturn
func fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers() {
        fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers("Inconsistent internal state.")
}
@noreturn
func fatalErrorDueToInconsistentInternalStateWithReportingToDevelopers(message: String) {
        reportToDevelopers(message)
        fatalError(message)
}


func reportToDevelopers(error: ErrorType) {
	reportToDevelopers("\(error)")
}
func reportToDevelopers(message: String) {
	debugLog(message)
}

















