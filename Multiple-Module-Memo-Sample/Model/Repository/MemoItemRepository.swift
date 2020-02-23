//
// Created by kawaharadai on 2020/02/23.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

protocol MemoItemRepository {
    func createMemoItem(text: String, uniqueId: String?, _ completion: (Result<Memo, Error>) -> ())

    func readAllMemos(_ completion: (Result<[Memo], Error>) -> ())

    func readMemo(at uniqueId: String, _ completion: (Result<Memo, Error>) -> ())

    func updateMemo(_ memo: Memo, text: String, _ completion: () -> ())

    func deleteAllMemos(entityName: String, _ completion: () -> ())

    func deleteMemo(at uniqueId: String, _ completion: () -> ())

    func countAllMemos(_ completion: () -> ())
}
