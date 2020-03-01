//
//  MemoItemRepositoryTest.swift
//  DataTests
//
//  Created by kawaharadai on 2020/03/01.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import XCTest
@testable import Data

class MemoItemRepositoryTest: XCTestCase {

    func test_createMemoItem_1件のメモを新規作成できること() {}

    func test_readAllMemos_保存中のメモを全件取得できること() {}

    func test_readMemo_ID指定で特定のメモを1件取得できること() {}

    func test_updateMemo_メモ内容を更新できること() {}

    func test_deleteAll_保存されているメモを全て削除できること() {}

    func test_deleteMemo_ID指定で1件のメモを削除できること() {}

    func test_countAll_保存されているメモの総数を取得できること() {}

}
