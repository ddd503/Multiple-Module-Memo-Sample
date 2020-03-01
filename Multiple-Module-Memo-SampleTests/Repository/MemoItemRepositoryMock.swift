//
//  MemoItemRepositoryMock.swift
//  Multiple-Module-Memo-SampleTests
//
//  Created by kawaharadai on 2020/03/01.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation
@testable import Data

class MemoItemRepositoryMock: MemoItemRepository {

    var dummyDataBase: [MemoItem] = []
    var isSuccessFunc = true
    let testError = NSError(domain: "MemoItemRepositoryMock", code: 998, userInfo: nil)

    func createMemoItem(text: String, uniqueId: String?, _ completion: (Result<MemoItem, Error>) -> ()) {
        let memoItem = MemoItemMock(
            uniqueId: uniqueId ?? "\(dummyDataBase.count + 1)",
            title: text.firstLine,
            content: text.afterSecondLine,
            editDate: nil)
        isSuccessFunc ? completion(.success(memoItem)) : completion(.failure(testError))
    }

    func readAllMemoItems(_ completion: (Result<[MemoItem], Error>) -> ()) {
        isSuccessFunc ? completion(.success(dummyDataBase)) : completion(.failure(testError))
    }

    func readMemoItem(at uniqueId: String, _ completion: (Result<MemoItem, Error>) -> ()) {
        let readMemoItem = dummyDataBase.filter { $0.uniqueId == uniqueId }.first!
        isSuccessFunc ? completion(.success(readMemoItem)) : completion(.failure(testError))
    }

    func updateMemoItem(uniqueId: String, text: String, _ completion: (Result<Void, Error>) -> ()) {
        let updateMemoItem = dummyDataBase.filter { $0.uniqueId == uniqueId }.first!
        updateMemoItem.title = text.firstLine
        updateMemoItem.content = text.afterSecondLine
        isSuccessFunc ? completion(.success(())) : completion(.failure(testError))
    }

    func deleteAllMemoItems(entityName: String, _ completion: (Result<Void, Error>) -> ()) {
        if entityName == "MemoItem" {
            dummyDataBase = []
        }
        isSuccessFunc ? completion(.success(())) : completion(.failure(testError))
    }

    func deleteMemoItem(at uniqueId: String, _ completion: (Result<Void, Error>) -> ()) {
        dummyDataBase = dummyDataBase.filter { $0.uniqueId != uniqueId }
        isSuccessFunc ? completion(.success(())) : completion(.failure(testError))
    }

    func countAllMemoItems(_ completion: (Int) -> ()) {
        completion(dummyDataBase.count)
    }

}
