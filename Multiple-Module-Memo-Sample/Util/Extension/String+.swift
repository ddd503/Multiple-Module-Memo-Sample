//
// Created by kawaharadai on 2020/02/24.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

extension String {
    /// 1行目のテキスト
    var firstLine: String {
        let lines = components(separatedBy: "\n")
        return lines.first ?? ""
    }

    /// 2行目以降のテキスト
    var afterSecondLine: String {
        var lines = components(separatedBy: "\n")
        guard lines.count > 1 else { return "" }
        // 1行目を削除
        lines.remove(at: 0)

        return lines.joined(separator: "\n")
    }
}
