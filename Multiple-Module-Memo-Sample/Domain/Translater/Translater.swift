//
//  Translater.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/29.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation
import Data

final class Translater {
    static func memoItemToMemo(memoItem: MemoItem) -> Memo {
        return Memo(uniqueId: memoItem.uniqueId,
                    title: memoItem.title,
                    content: memoItem.content,
                    editDate: memoItem.editDate)
    }
    
    static func memoItemsToMemos(memoItems: [MemoItem]) -> [Memo] {
        return memoItems.map { Memo(uniqueId: $0.uniqueId,
                                    title: $0.title,
                                    content: $0.content,
                                    editDate: $0.editDate) }
    }
}
