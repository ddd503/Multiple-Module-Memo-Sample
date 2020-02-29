//
//  MemoItemDataStoreTest.swift
//  DataTests
//
//  Created by kawaharadai on 2020/03/01.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import XCTest
import CoreData
@testable import Data

class MemoItemDataStoreTest: XCTestCase {

    override func setUp() {
        deleteAllMemo()
    }

    override func tearDown() {
        deleteAllMemo()
    }

    func test_create_任意のEntityを新規作成できること() {
        let expectation = self.expectation(description: "任意のEntityを新規作成できること")
        let dataStore = MemoItemDataStoreImpl()
        dataStore.create(entityName: "MemoItem") { (result: Result<MemoItem, Error>) in
            switch result {
            case .success(let memoItem):
                XCTAssertNotNil(memoItem.uniqueId)
                memoItem.managedObjectContext?.delete(memoItem)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchArray_条件を指定してEntityの配列を取得できること() {
        let expectation = self.expectation(description: "条件を指定してEntityの配列を取得できること")
        let entityName = "MemoItem"
        let dataStore = MemoItemDataStoreImpl()
        let group = DispatchGroup()

        (0..<3).forEach { i in
            group.enter()
            dataStore.create(entityName: entityName) { (result: Result<MemoItem, Error>) in
                switch result {
                case .success(let memoItem):
                    memoItem.uniqueId = "テスト\(i)"
                    dataStore.save(context: memoItem.managedObjectContext!)
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let predicate1 = NSPredicate(format: "uniqueId == %@", "テスト1")
            let predicate2 = NSPredicate(format: "uniqueId == %@", "テスト2")
            dataStore.fetchArray(predicates: [predicate1, predicate2],
                                 sortKey: "editDate",
                                 ascending: false,
                                 logicalType: .or) { (result: Result<[MemoItem], Error>) in
                                    switch result {
                                    case .success(let memoItems):
                                        XCTAssertEqual(memoItems.count, 2)
                                    case .failure(let error):
                                        XCTFail(error.localizedDescription)
                                    }
                                    expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_リクエストが実行されていること() {
        let expectation = self.expectation(description: "リクエストが実行されていること")
        let entityName = "MemoItem"
        let allMemoItemsCount = 100
        let dataStore = MemoItemDataStoreImpl()
        let group = DispatchGroup()

        (0..<allMemoItemsCount).forEach { i in
            group.enter()
            dataStore.create(entityName: entityName) { (result: Result<MemoItem, Error>) in
                switch result {
                case .success(let memoItem):
                    memoItem.uniqueId = "テスト\(i)"
                    dataStore.save(context: memoItem.managedObjectContext!)
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let sortKey = "editDate"
            let ascending = false
            let logicalType = NSCompoundPredicate.LogicalType.and
            dataStore
                .fetchArray(predicates: [],
                            sortKey: sortKey,
                            ascending: ascending,
                            logicalType: logicalType) { (result: Result<[MemoItem], Error>) in
                                switch result {
                                case .success(let memoItems):
                                    XCTAssertEqual(memoItems.count, allMemoItemsCount,
                                                   "削除実行前はallMemosCount分の要素があるはず")

                                    // 削除リクエストの実行
                                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                                    dataStore.execute(request: deleteRequest) { result in
                                        switch result {
                                        case .success(_):
                                            dataStore
                                                .fetchArray(predicates: [],
                                                            sortKey: sortKey,
                                                            ascending: ascending,
                                                            logicalType: logicalType) { (result: Result<[MemoItem], Error>) in
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
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func test_delete_指定した1件のEntityを削除できること() {
        let expectation = self.expectation(description: "指定した1件のEntityを削除できること")
        let entityName = "MemoItem"
        let allMemoItemsCount = 3
        let dataStore = MemoItemDataStoreImpl()
        let group = DispatchGroup()
        var dummyArray = [MemoItem]()

        (0..<allMemoItemsCount).forEach { i in
            group.enter()
            dataStore.create(entityName: entityName) { (result: Result<MemoItem, Error>) in
                switch result {
                case .success(let memoItem):
                    memoItem.uniqueId = "\(i)"
                    dataStore.save(context: memoItem.managedObjectContext!)
                    dummyArray.append(memoItem)
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let sortKey = "editDate"
            let ascending = false
            let logicalType = NSCompoundPredicate.LogicalType.and
            dataStore
                .fetchArray(predicates: [],
                            sortKey: sortKey,
                            ascending: ascending,
                            logicalType: logicalType) { (result: Result<[MemoItem], Error>) in
                                switch result {
                                case .success(let memoItems):
                                    XCTAssertEqual(memoItems.count, allMemoItemsCount,
                                                   "削除実行前はallMemosCount分の要素があるはず")
                                    // uniqueIdが2のMemoItemを削除を削除
                                    let memoItem2 = dummyArray.filter { $0.uniqueId == "2" }.first!
                                    dataStore.delete(object: memoItem2) {
                                        dataStore.fetchArray(predicates: [],
                                                             sortKey: sortKey,
                                                             ascending: ascending,
                                                             logicalType: logicalType) { (result: Result<[MemoItem], Error>) in
                                                                switch result {
                                                                case .success(let memoItems):
                                                                    XCTAssertEqual(memoItems.count, 2, "削除実行後は要素数は2つのはず")
                                                                    XCTAssertFalse(memoItems.contains(where: { $0.uniqueId == "2" }), "idが2のメモが含まれていないこと")
                                                                    expectation.fulfill()
                                                                case .failure(let error):
                                                                    XCTFail(error.localizedDescription)
                                                                }
                                        }
                                    }
                                case .failure(let error):
                                    XCTFail(error.localizedDescription)
                                }
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    private func deleteAllMemo() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! context.execute(deleteRequest)
    }

}
