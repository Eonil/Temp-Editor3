//
//  MenuItemController.swift
//  Editor3
//
//  Created by Hoon H. on 2016/04/18.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class MenuItemController: NSObject {
        let code: Menu2Code
        let item: NSMenuItem
        var subcontrollers: [MenuItemController] {
                willSet {
                        item.submenu?.removeAllItems()
                        item.submenu = nil
                }
                didSet {
                        let m = NSMenu(title: code.getLabel())
                        m.autoenablesItems = false
                        for s in subcontrollers {
                                m.addItem(s.item)
                                item.submenu = m
                        }
                }
        }
        var onEvent: (Menu2Code->())?

        init(code: Menu2Code) {
                self.code = code
                switch code {
                case .Separator:
                        item = NSMenuItem.separatorItem()
                        subcontrollers = []
                        super.init()
                default:
                        item = NSMenuItem()
                        subcontrollers = []
                        super.init()
                        item.enabled = false
                        item.title = code.getLabel()
                        item.keyEquivalentModifierMask = Int(bitPattern: code.getKeyModifiersAndEquivalentPair().keyModifier.rawValue)
                        item.keyEquivalent = code.getKeyModifiersAndEquivalentPair().keyEquivalent
                        item.target = self
                        item.action = #selector(EDITOR_onClick(_:))
                }
        }
        var enabled: Bool {
                get {
                        return item.enabled
                }
                set {
                        item.enabled = newValue
                }
        }
//        func putAllCodeToControllersIntoMapping(inout mapping: [Menu2Code: [MenuItemController]]) {
//                var list = mapping[code] ?? []
//                list.append(self)
//                mapping[code] = list
//                for s in subcontrollers {
//                        s.putAllCodeToControllersIntoMapping(&mapping)
//                }
//        }
        @objc
        private func EDITOR_onClick(_: AnyObject?) {
                assert(onEvent != nil)
                onEvent?(code)
        }
}
private extension Menu2Code {
        private func makeItemController() -> MenuItemController {
                return MenuItemController(code: self)
        }
}

