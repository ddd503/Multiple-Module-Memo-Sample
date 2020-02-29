//
//  Translater.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/29.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation

final class Translater {
    static func memoToMemoInfo(memo: Memo) -> MemoInfo {
        return MemoInfo(uniqueId: memo.uniqueId,
                        title: memo.title,
                        content: memo.content,
                        editDate: memo.editDate)
    }

    static func memosToMemoInfos(memos: [Memo]) -> [MemoInfo] {
        return memos.map { MemoInfo(uniqueId: $0.uniqueId,
                                    title: $0.title,
                                    content: $0.content,
                                    editDate: $0.editDate) }
    }
}
