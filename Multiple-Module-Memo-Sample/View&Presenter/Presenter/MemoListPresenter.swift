//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

protocol MemoListPresenterInputs {}

protocol MemoListPresenterOutputs: class {
    init(presenterInput: MemoListPresenterInputs)
}

final class MemoListPresenter: MemoListPresenterInputs {

    weak var output: MemoListPresenterOutputs?
    private let memoItemRepository: MemoItemRepository

    init(memoItemRepository: MemoItemRepository) {
        self.memoItemRepository = memoItemRepository
    }
}