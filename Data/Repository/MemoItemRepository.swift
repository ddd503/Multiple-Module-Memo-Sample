//
//  MemoItemRepository.swift
//  Data
//
//  Created by kawaharadai on 2020/02/29.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import Foundation
import CoreData

protocol MemoItemRepository {
    func createMemoItem(text: String, uniqueId: String?, _ completion: (Result<MemoItem, Error>) -> ())

    func readAllMemos(_ completion: (Result<[MemoItem], Error>) -> ())

    func readMemo(at uniqueId: String, _ completion: (Result<MemoItem, Error>) -> ())

    func updateMemo(uniqueId: String, text: String, _ completion: (Result<Void, Error>) -> ())

    func deleteAllMemos(entityName: String, _ completion: (Result<Void, Error>) -> ())

    func deleteMemo(at uniqueId: String, _ completion: (Result<Void, Error>) -> ())

    func countAllMemos(_ completion: (Int) -> ())
}

struct MemoItemRepositoryImpl: MemoItemRepository {

    let memoItemDataStore: MemoItemDataStore

    init(memoItemDataStore: MemoItemDataStore) {
        self.memoItemDataStore = memoItemDataStore
    }

    func createMemoItem(text: String, uniqueId: String?, _ completion: (Result<MemoItem, Error>) -> ()) {
        memoItemDataStore.create(entityName: "MemoItem") { (result: Result<MemoItem, Error>) in
            switch result {
            case .success(let memo):
                guard let context = memo.managedObjectContext else {
                    completion(.failure(CoreDataError.notFoundContext))
                    return
                }
                context.performAndWait {
                    memo.title = text.firstLine
                    memo.content = text.afterSecondLine
                    memo.editDate = Date()
                    if let uniqueId = uniqueId {
                        memo.uniqueId = uniqueId
                    } else {
                        countAllMemos { count in
                            memo.uniqueId = "\(count)"
                        }
                    }
                    self.memoItemDataStore.save(context: context)
                }
                completion(.success(memo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func readAllMemos(_ completion: (Result<[MemoItem], Error>) -> ()) {
        memoItemDataStore.fetchArray(
            predicates: [],
            sortKey: "editDate",
            ascending: false,
            logicalType: .and) { (result: Result<[MemoItem], Error>) in
                completion(result)
        }
    }

    func readMemo(at uniqueId: String, _ completion: (Result<MemoItem, Error>) -> ()) {
        memoItemDataStore.fetchArray(
            predicates: [NSPredicate(format: "uniqueId == %@", uniqueId)],
            sortKey: "editDate",
            ascending: false,
            logicalType: .and) { (result: Result<[MemoItem], Error>) in
                switch result {
                case .success(let memos):
                    guard !memos.isEmpty else {
                        completion(.failure(CoreDataError.failedFetchMemoById))
                        return
                    }
                    completion(.success(memos[0]))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    func updateMemo(uniqueId: String, text: String, _ completion: (Result<Void, Error>) -> ()) {
        readMemo(at: uniqueId) { result in
            switch result {
            case .success(let memo):
                guard let context = memo.managedObjectContext else {
                    completion(.failure(CoreDataError.notFoundContext))
                    return
                }
                context.performAndWait {
                    memo.title = text.firstLine
                    memo.content = text.afterSecondLine
                    memo.editDate = Date()
                }
                completion(memoItemDataStore.save(context: context))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteAllMemos(entityName: String, _ completion: (Result<Void, Error>) -> ()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        memoItemDataStore.execute(request: deleteRequest) { result in
            completion(result)
        }
    }

    func deleteMemo(at uniqueId: String, _ completion: (Result<Void, Error>) -> ()) {
        readMemo(at: uniqueId) { result in
            switch result {
            case .success(let memo):
                memoItemDataStore.delete(object: memo) {
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func countAllMemos(_ completion: (Int) -> ()) {
        readAllMemos { result in
            switch result {
            case .success(let memos):
                completion(memos.count)
            case .failure(_):
                completion(0)
            }
        }
    }
}
