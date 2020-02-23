//
// Created by kawaharadai on 2020/02/23.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

protocol MemoItemRepository {
    func createMemoItem(text: String, uniqueId: String?, _ completion: (Result<Memo, Error>) -> (Void))

    func readAllMemos(_ completion: (Result<[Memo], Error>) -> Void)

    func readMemo(at uniqueId: String, _ completion: (Result<Memo, Error>) -> (Void))

    func updateMemo(_ memo: Memo, text: String, _ completion: (Void) -> (Void))

    func deleteAllMemos(entityName: String, _ completion: (Void) -> (Void))

    func deleteMemo(at uniqueId: String, _ completion: (Void) -> (Void))

    func countAllMemos(_ completion: (Void) -> (Void))
}
