//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

protocol MemoDetailPresenterInputs {
    var memoItemRepository: MemoItemRepository { get }
    var memoItem: Memo? { get }
    func viewDidLoad()
    func tappedDoneButton(textViewText: String)
    func didSaveMemo(_ notification: Notification)
}

protocol MemoDetailPresenterOutputs: class {
    init(presenterInput: MemoListPresenterInputs)
    func setupText(_ initialText: String?)
    func returnMemoList()
    func showErrorAlert(message: String?)
}

final class MemoDetailPresenter: MemoDetailPresenterInputs {

    weak var output: MemoDetailPresenterOutputs?
    let memoItemRepository: MemoItemRepository
    let memoItem: Memo?

    init(memoItemRepository: MemoItemRepository, memoItem: Memo?) {
        self.memoItemRepository = memoItemRepository
        self.memoItem = memoItem
    }

    func viewDidLoad() {
        output?.setupText((memoItem?.title ?? "") + "\n" + (memoItem?.content ?? ""))
    }

    func tappedDoneButton(textViewText: String) {
        if let memoItem = memoItem {
            // 既存メモの更新
            memoItemRepository.updateMemo(memoItem, text: textViewText) { [weak self] result in
                switch result {
                case .success(_): break
                case .failure(let error):
                    self?.output?.showErrorAlert(message: error.localizedDescription)
                }
            }
        } else {
            // 新規メモの作成
            memoItemRepository.createMemoItem(text: textViewText, uniqueId: nil) { [weak self] result in
                switch result {
                case .success(_): break
                case .failure(let error):
                   self?.output?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }

    func didSaveMemo(_ notification: Notification) {
        output?.returnMemoList()
    }
}