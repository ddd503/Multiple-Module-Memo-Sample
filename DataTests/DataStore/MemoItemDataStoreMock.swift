//
//  MemoItemDataStoreMock.swift
//  DataTests
//
//  Created by kawaharadai on 2020/03/01.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation
import CoreData
@testable import Data

class MemoItemDataStoreMock: MemoItemDataStore {

    var dummyDataBase: [MemoItem] = []
    var isSuccessFunc = true
    let testError = NSError(domain: "MemoItemDataStoreMock", code: 999, userInfo: nil)

    func create<T>(entityName: String, _ completion: (Result<T, Error>) -> ()) where T : NSManagedObject {
        let memoItem = MemoItemMock() as! T
        isSuccessFunc ? completion(.success(memoItem)) : completion(.failure(testError))
    }

    func save(context: NSManagedObjectContext) -> Result<Void, Error> {
        return isSuccessFunc ? .success(()) : .failure(testError)
    }

    func fetchArray<T>(predicates: [NSPredicate],
                       sortKey: String,
                       ascending: Bool,
                       logicalType: NSCompoundPredicate.LogicalType,
                       _ completion: (Result<[T], Error>) -> ()) where T : NSManagedObject {
        let predicate = NSCompoundPredicate(type: logicalType, subpredicates: predicates)
        let fetchResult = (dummyDataBase as NSArray).filtered(using: predicate) as! [T]
        isSuccessFunc ? completion(.success(fetchResult)) : completion(.failure(testError))
    }

    func execute<R>(request: R, _ completion: (Result<Void, Error>) -> ()) where R : NSPersistentStoreRequest {
        if let deleteRequest = request as? NSBatchDeleteRequest,
            let entityName = deleteRequest.fetchRequest.entityName,
            entityName == "MemoItem" {
            // MemoItem全削除時
            dummyDataBase = []
        }
        isSuccessFunc ? completion(.success(())) : completion(.failure(testError))
    }

    func delete<T>(object: T, _ completion: () -> ()) where T : NSManagedObject {
        let memoItem = object as! MemoItem
        dummyDataBase = dummyDataBase.filter { $0.uniqueId != memoItem.uniqueId }
        completion()
    }

}
