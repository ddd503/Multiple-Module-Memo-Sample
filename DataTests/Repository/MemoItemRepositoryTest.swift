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

    func test_createMemoItem_1件のメモを新規作成できること() {
        let expectation = self.expectation(description: "1件のメモを新規作成できること")
        let dataStore = MemoItemDataStoreMock()
        let repository = MemoItemRepositoryImpl(memoItemDataStore: dataStore)

        repository.createMemoItem(text: "タイトル1\nコンテンツ1\nコンテンツ2", uniqueId: nil) { result in
            switch result {
            case .success(let createMemoItem):
                XCTAssertEqual(createMemoItem.uniqueId, "1")
                XCTAssertEqual(createMemoItem.title, "タイトル1")
                XCTAssertEqual(createMemoItem.content, "コンテンツ1\nコンテンツ2")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_readAllMemoItems_保存中のメモを全件取得できること() {
        let expectation = self.expectation(description: "保存中のメモを全件取得できること")
        let dataStore = MemoItemDataStoreMock()
        let allMemoItemsCount = 100
        let repository = MemoItemRepositoryImpl(memoItemDataStore: dataStore)

        (0..<allMemoItemsCount).forEach {
            let memoItem = MemoItemMock(uniqueId: "\($0)")
            dataStore.dummyDataBase.append(memoItem)
        }

        repository.readAllMemoItems { result in
            switch result {
            case .success(let memoItems):
                XCTAssertEqual(memoItems.count, allMemoItemsCount)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_readMemoItem_ID指定で特定のメモを1件取得できること() {
        let expectation = self.expectation(description: "ID指定で特定のメモを1件取得できること")
        let dataStore = MemoItemDataStoreMock()
        let repository = MemoItemRepositoryImpl(memoItemDataStore: dataStore)

        let dummyUniqueId1 = "1000"
        let dummyTitle1 = "title1"
        let dummyContent1 = "content1"
        let memoItem1 = MemoItemMock(uniqueId: dummyUniqueId1, title: dummyTitle1, content: dummyContent1)
        dataStore.dummyDataBase.append(memoItem1)
        let dummyUniqueId2 = "2000"
        let dummyTitle2 = "title2"
        let dummyContent2 = "content2"
        let memoItem2 = MemoItemMock(uniqueId: dummyUniqueId2, title: dummyTitle2, content: dummyContent2)
        dataStore.dummyDataBase.append(memoItem2)
        let dummyUniqueId3 = "3000"
        let dummyTitle3 = "title3"
        let dummyContent3 = "content3"
        let memoItem3 = MemoItemMock(uniqueId: dummyUniqueId3, title: dummyTitle3, content: dummyContent3)
        dataStore.dummyDataBase.append(memoItem3)

        repository.readMemoItem(at: dummyUniqueId2) { result in
            switch result {
            case .success(let memoItem):
                XCTAssertEqual(memoItem.uniqueId, dummyUniqueId2)
                XCTAssertEqual(memoItem.title, dummyTitle2)
                XCTAssertEqual(memoItem.content, dummyContent2)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_updateMemoItem_メモ内容を更新できること() {
        let expectation = self.expectation(description: "メモ内容を更新できること")
        let dataStore = MemoItemDataStoreMock()
        let repository = MemoItemRepositoryImpl(memoItemDataStore: dataStore)

        let dummyUniqueId1 = "1000"
        let dummyTitle1 = "title1"
        let dummyContent1 = "content1"
        let memoItem1 = MemoItemMock(uniqueId: dummyUniqueId1, title: dummyTitle1, content: dummyContent1)
        dataStore.dummyDataBase.append(memoItem1)
        let dummyUniqueId2 = "2000"
        let dummyTitle2 = "title2"
        let dummyContent2 = "content2"
        let memoItem2 = MemoItemMock(uniqueId: dummyUniqueId2, title: dummyTitle2, content: dummyContent2)
        dataStore.dummyDataBase.append(memoItem2)

        // memoItem1を更新する
        repository.updateMemoItem(uniqueId: dummyUniqueId1, text: "updateTitle1\nupdateContent1") { result in
            switch result {
            case .success(_):
                // 更新結果を評価
                repository.readMemoItem(at: dummyUniqueId1) { fetchResult in
                    switch fetchResult {
                    case .success(let memoItem):
                        XCTAssertEqual(memoItem.uniqueId, dummyUniqueId1)
                        XCTAssertEqual(memoItem.title, "updateTitle1")
                        XCTAssertEqual(memoItem.content, "updateContent1")
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_deleteAllMemoItems_保存されているメモを全て削除できること() {
        let expectation = self.expectation(description: "保存されているメモを全て削除できること")
        let dataStore = MemoItemDataStoreMock()
        let allMemoItemsCount = 100
        let repository = MemoItemRepositoryImpl(memoItemDataStore: dataStore)

        (0..<allMemoItemsCount).forEach {
            let memoItem = MemoItemMock(uniqueId: "\($0)")
            dataStore.dummyDataBase.append(memoItem)
        }

        repository.readAllMemoItems { result in
            switch result {
            case .success(let memoItems):
                XCTAssertEqual(memoItems.count, allMemoItemsCount)
                repository.deleteAllMemoItems(entityName: "MemoItem") { result in
                    switch result {
                    case .success(_):
                        repository.readAllMemoItems { result in
                            switch result {
                            case .success(let memoItems):
                                XCTAssertEqual(memoItems.count, 0)
                            case .failure(let error):
                                XCTFail(error.localizedDescription)
                            }
                            expectation.fulfill()
                        }
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    }
                }
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func test_deleteMemoItem_ID指定で1件のメモを削除できること() {
        let expectation = self.expectation(description: "ID指定で1件のメモを削除できること")
        let dataStore = MemoItemDataStoreMock()
        let repository = MemoItemRepositoryImpl(memoItemDataStore: dataStore)

        let dummyUniqueId1 = "1000"
        let dummyTitle1 = "title1"
        let dummyContent1 = "content1"
        let memoItem1 = MemoItemMock(uniqueId: dummyUniqueId1, title: dummyTitle1, content: dummyContent1)
        dataStore.dummyDataBase.append(memoItem1)
        let dummyUniqueId2 = "2000"
        let dummyTitle2 = "title2"
        let dummyContent2 = "content2"
        let memoItem2 = MemoItemMock(uniqueId: dummyUniqueId2, title: dummyTitle2, content: dummyContent2)
        dataStore.dummyDataBase.append(memoItem2)
        let dummyUniqueId3 = "3000"
        let dummyTitle3 = "title3"
        let dummyContent3 = "content3"
        let memoItem3 = MemoItemMock(uniqueId: dummyUniqueId3, title: dummyTitle3, content: dummyContent3)
        dataStore.dummyDataBase.append(memoItem3)

        repository.readAllMemoItems { result in
            switch result {
            case .success(let memoItems):
                XCTAssertEqual(memoItems.count, 3)
                repository.deleteMemoItem(at: dummyUniqueId3) { result in
                    switch result {
                    case .success(_):
                        repository.readAllMemoItems { result in
                            switch result {
                            case .success(let memoItems):
                                XCTAssertEqual(memoItems.count, 2)
                                XCTAssertEqual(memoItems.compactMap { $0.uniqueId }.count, 2)
                                XCTAssertTrue(memoItems.compactMap { $0.uniqueId }.contains(dummyUniqueId1))
                                XCTAssertTrue(memoItems.compactMap { $0.uniqueId }.contains(dummyUniqueId2))
                                XCTAssertFalse(memoItems.compactMap { $0.uniqueId }.contains(dummyUniqueId3))
                            case .failure(let error):
                                XCTFail(error.localizedDescription)
                            }
                            expectation.fulfill()
                        }
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    }
                }
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_countAllMemoItems_保存されているメモの総数を取得できること() {
        let expectation = self.expectation(description: "保存されているメモの総数を取得できること")
        let dataStore = MemoItemDataStoreMock()
        let allMemoItemsCount = 150
        let repository = MemoItemRepositoryImpl(memoItemDataStore: dataStore)

        (0..<allMemoItemsCount).forEach {
            let memoItem = MemoItemMock(uniqueId: "\($0)")
            dataStore.dummyDataBase.append(memoItem)
        }

        repository.countAllMemoItems { count in
            XCTAssertEqual(count, allMemoItemsCount)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

}
