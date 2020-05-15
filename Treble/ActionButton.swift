//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

typealias ActionHandler = () -> Void
class ActionButton : UIButton {
    private var actionHandler: ActionHandler?

    convenience init(image: UIImage?, style: UIFont.TextStyle = .title3, scale: UIImage.SymbolScale = .default) {
        self.init(type: .custom)
        setImage(image, for: .normal)
        setPreferredSymbolConfiguration(.init(textStyle: style, scale: scale), forImageIn: .normal)
    }

    func addAction(handler: ActionHandler?) {
        if actionHandler == nil && handler != nil {
            addTarget(self, action: #selector(invokePrimaryAction), for: .primaryActionTriggered)
        } else if handler == nil && actionHandler != nil {
            removeTarget(self, action: #selector(invokePrimaryAction), for: .primaryActionTriggered)
        }
        actionHandler = handler
    }

    @objc private func invokePrimaryAction() {
        actionHandler?()
    }
}
