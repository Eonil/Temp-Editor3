//
//  CommonViewController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/01.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Remove NIB stuffs.
class CommonViewController: NSViewController {

        // MARK: -
        override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
                assert(nibNameOrNil == nil)
                assert(nibBundleOrNil == nil)
                preconditionAndReportFailureToDevelopers(nibNameOrNil == nil)
                preconditionAndReportFailureToDevelopers(nibBundleOrNil == nil)
                super.init(nibName: nil, bundle: nil)
        }
        @available(*,unavailable)
        required init?(coder: NSCoder) {
                fatalError("IB/SB are unsupported.")
        }

        // MARK: -
        override func loadView() {
                self.view = CommonView()
        }
}
