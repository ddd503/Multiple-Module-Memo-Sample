//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

protocol MemoDetailPresenterInputs {}

protocol MemoDetailPresenterOutputs: class {
    init(presenterInput: MemoListPresenterInputs)
}

final class MemoDetailPresenter: MemoDetailPresenterInputs {

    weak var output: MemoDetailPresenterOutputs?
    private let memoItemRepository: MemoItemRepository

    init(memoItemRepository: MemoItemRepository) {
        self.memoItemRepository = memoItemRepository
    }
}