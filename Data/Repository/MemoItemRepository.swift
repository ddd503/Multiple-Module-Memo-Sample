//
//  MemoItemRepository.swift
//  Data
//
//  Created by kawaharadai on 2020/02/29.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation
import CoreData

public protocol MemoItemRepository {
    func createMemoItem(text: String, uniqueId: String?, _ completion: (Result<MemoItem, Error>) -> ())

    func readAllMemoItems(_ completion: (Result<[MemoItem], Error>) -> ())

    func readMemoItem(at uniqueId: String, _ completion: (Result<MemoItem, Error>) -> ())

    func updateMemoItem(uniqueId: String, text: String, _ completion: (Result<Void, Error>) -> ())

    func deleteAllMemoItems(entityName: String, _ completion: (Result<Void, Error>) -> ())

    func deleteMemoItem(at uniqueId: String, _ completion: (Result<Void, Error>) -> ())

    func countAllMemoItems(_ completion: (Int) -> ())
}

public struct MemoItemRepositoryImpl: MemoItemRepository {

    let memoItemDataStore: MemoItemDataStore

    public init(memoItemDataStore: MemoItemDataStore) {
        self.memoItemDataStore = memoItemDataStore
    }

    public func createMemoItem(text: String, uniqueId: String?, _ completion: (Result<MemoItem, Error>) -> ()) {
        memoItemDataStore.create(entityName: "MemoItem") { (result: Result<MemoItem, Error>) in
            switch result {
            case .success(let memoItem):
                guard let context = memoItem.managedObjectContext else {
                    completion(.failure(CoreDataError.notFoundContext))
                    return
                }
                context.performAndWait {
                    memoItem.title = text.firstLine
                    memoItem.content = text.afterSecondLine
                    memoItem.editDate = Date()
                    if let uniqueId = uniqueId {
                        memoItem.uniqueId = uniqueId
                    } else {
                        countAllMemoItems { count in
                            memoItem.uniqueId = "\(count + 1)"
                        }
                    }
                    self.memoItemDataStore.save(object: memoItem)
                }
                completion(.success(memoItem))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func readAllMemoItems(_ completion: (Result<[MemoItem], Error>) -> ()) {
        memoItemDataStore.fetchArray(
            predicates: [],
            sortKey: "editDate",
            ascending: false,
            logicalType: .and) { (result: Result<[MemoItem], Error>) in
                completion(result)
        }
    }

    public func readMemoItem(at uniqueId: String, _ completion: (Result<MemoItem, Error>) -> ()) {
        memoItemDataStore.fetchArray(
            predicates: [NSPredicate(format: "uniqueId == %@", uniqueId)],
            sortKey: "editDate",
            ascending: false,
            logicalType: .and) { (result: Result<[MemoItem], Error>) in
                switch result {
                case .success(let memoItems):
                    guard !memoItems.isEmpty else {
                        completion(.failure(CoreDataError.failedFetchMemoById))
                        return
                    }
                    completion(.success(memoItems[0]))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    public func updateMemoItem(uniqueId: String, text: String, _ completion: (Result<Void, Error>) -> ()) {
        readMemoItem(at: uniqueId) { result in
            switch result {
            case .success(let memoItem):
                guard let context = memoItem.managedObjectContext else {
                    completion(.failure(CoreDataError.notFoundContext))
                    return
                }
                context.performAndWait {
                    memoItem.title = text.firstLine
                    memoItem.content = text.afterSecondLine
                    memoItem.editDate = Date()
                }
                completion(memoItemDataStore.save(object: memoItem))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func deleteAllMemoItems(entityName: String, _ completion: (Result<Void, Error>) -> ()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        memoItemDataStore.execute(request: deleteRequest) { result in
            completion(result)
        }
    }

    public func deleteMemoItem(at uniqueId: String, _ completion: (Result<Void, Error>) -> ()) {
        readMemoItem(at: uniqueId) { result in
            switch result {
            case .success(let memoItem):
                memoItemDataStore.delete(object: memoItem) {
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func countAllMemoItems(_ completion: (Int) -> ()) {
        readAllMemoItems { result in
            switch result {
            case .success(let memoItems):
                completion(memoItems.count)
            case .failure(_):
                completion(0)
            }
        }
    }
}
