//
//  Memo.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/29.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation

struct Memo {
    let uniqueId: String
    let title: String
    let content: String
    let editDate: Date?

    init(uniqueId: String?, title: String?, content: String?, editDate: Date?) {
        self.uniqueId = uniqueId ?? ""
        self.title = title ?? ""
        self.content = content ?? ""
        self.editDate = editDate
    }
}
