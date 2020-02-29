//
//  ViewControllerBuilder.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/27.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

final class ViewControllerBuilder {
    static func buildMemoListVC() -> MemoListViewController {
        let memoItemDataStore = MemoItemDataStoreImpl()
        let memoItemRepository = MemoItemRepositoryImpl(memoItemDataStore: memoItemDataStore)
        let memoListPresenter = MemoListPresenter(memoItemRepository: memoItemRepository)
        return MemoListViewController(presenterInputs: memoListPresenter)
    }

    static func buildMemoDetailVC(memo: MemoInfo? = nil) -> MemoDetailViewController {
        let memoItemDataStore = MemoItemDataStoreImpl()
        let memoItemRepository = MemoItemRepositoryImpl(memoItemDataStore: memoItemDataStore)
        let memoDetailPresenter = MemoDetailPresenter(memoItemRepository: memoItemRepository, memoItem: memo)
        return MemoDetailViewController(presenterInputs: memoDetailPresenter)
    }
}
