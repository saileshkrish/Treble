//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

func ==(lhs: PlaybackRate, rhs: PlaybackRate) -> Bool {
    switch (lhs, rhs) {
    case (.slower, .slower), (.slow, .slow), (.normal, .normal), (.fast, .fast), (.faster, .faster):
        return true
    case (.custom(let lhs), .custom(let rhs)):
        return lhs == rhs
    default:
        return false
    }
}

enum PlaybackRate: Equatable {
    case slower
    case slow
    case normal
    case fast
    case faster
    case custom(Float)

    static let allCases: [PlaybackRate] = [.slower, .slow, .normal, .fast, .faster]

    init(rate: Float) {
        switch rate {
        case 0.50: self = .slower
        case 0.75: self = .slow
        case 1.00: self = .normal
        case 1.55: self = .fast
        case 2.00: self = .faster
        default: self = .custom(rate)
        }
    }

    var rate: Float {
        switch self {
        case .slower: return 0.5
        case .slow: return 0.75
        case .normal: return 1.0
        case .fast: return 1.25
        case .faster: return 1.5
        case .custom(let value): return value
        }
    }

    var rateTitle: String { "\(rate)x" }

    var title: String {
        switch self {
        case .slower:   return "Slower"
        case .slow:     return "Slow"
        case .normal:   return "Normal"
        case .fast:     return "Fast"
        case .faster:   return "Faster"
        case .custom(let value): return "\(value)x"
        }
    }

    var next: PlaybackRate {
        switch self {
        case .slower:   return .slow
        case .slow:     return .normal
        case .normal:   return .fast
        case .fast:     return .faster
        case .faster:   return .slower
        case .custom:   return .normal
        }
    }
}

typealias PlaybackRateHandler = (PlaybackRate) -> Void
class PlaybackRateButton : UIButton {
    private var onRateChangeHandler: PlaybackRateHandler?
    private var rate: PlaybackRate = .normal {
        didSet {
            setTitle(rate.rateTitle, for: .normal)
            self.onRateChangeHandler?(self.rate)
        }
    }

    convenience init() {
        self.init(type: .custom)
        setTitle(rate.rateTitle, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: .title3)
        addTarget(self, action: #selector(didTapButton(_:)), for: .primaryActionTriggered)
        addInteraction(UIContextMenuInteraction(delegate: self))
    }

    @objc private func didTapButton(_ button: UIButton) {
        self.rate = rate.next
    }

    func onRateChange(_ handler: @escaping PlaybackRateHandler) {
        self.onRateChangeHandler = handler
    }

    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: PlaybackRate.allCases.map { newRate in
                UIAction(title: newRate.title, state: self.rate == newRate ? .on : .off) { _ in
                    self.rate = newRate
                }
            })
        }
    }
}
