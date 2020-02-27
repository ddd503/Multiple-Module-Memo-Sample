//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import UIKit

// アラート表示、タップ時のアクションまでに関する情報まとめ用
struct AlertEvent {
    let title: String?
    let message: String?
    let style: UIAlertAction.Style
    let actionType: AlertActionType

    init(title: String? = nil, message: String? = nil, style: UIAlertAction.Style, actionType: AlertActionType) {
        self.title = title
        self.message = message
        self.style = style
        self.actionType = actionType
    }
}

// アラートタップ時のアクション種別
enum AlertActionType {
    case allDelete
    case cancel

    var event: AlertEvent {
        switch self {
        case .allDelete:
            return AlertEvent(title: "すべて削除", style: .destructive, actionType: .allDelete)
        case .cancel:
            return AlertEvent(title: "キャンセル", style: .cancel, actionType: .cancel)
        }
    }
}

extension UIViewController {
    func showAlert(title: String? = nil, message: String? = nil,
                   style: UIAlertController.Style, actions: [AlertEvent],
                   handler: @escaping (AlertEvent) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { event in
            let action = UIAlertAction(title: event.title, style: event.style) { _ in
                handler(event)
            }
            alert.addAction(action)
        }
        self.present(alert, animated: true)
    }

    func showNormalErrorAlert(message: String? = nil) {
        let message = message ?? "一時的な不具合が発生しました。\n一定時間待ってからお試しください。"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let close = UIAlertAction(title: "とじる", style: .default, handler: nil)
        alert.addAction(close)
        self.present(alert, animated: true)
    }
}
