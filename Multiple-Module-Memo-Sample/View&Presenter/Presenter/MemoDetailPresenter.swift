//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

protocol MemoDetailPresenterInputs {
    var memoItemRepository: MemoItemRepository { get }
    var memoItem: Memo? { get }
    func bind(view: MemoDetailPresenterOutputs)
    func viewDidLoad()
    func tappedDoneButton(textViewText: String)
    func didSaveMemo(_ notification: Notification)
}

protocol MemoDetailPresenterOutputs: class {
    init(presenterInputs: MemoDetailPresenterInputs)
    func setupText(_ initialText: String?)
    func returnMemoList()
    func showErrorAlert(message: String?)
}

final class MemoDetailPresenter: MemoDetailPresenterInputs {

    weak var view: MemoDetailPresenterOutputs?
    let memoItemRepository: MemoItemRepository
    let memoItem: Memo?

    init(memoItemRepository: MemoItemRepository, memoItem: Memo?) {
        self.memoItemRepository = memoItemRepository
        self.memoItem = memoItem
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSaveMemo(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
    }

    func bind(view: MemoDetailPresenterOutputs) {
        self.view = view
    }

    func viewDidLoad() {
        view?.setupText((memoItem?.title ?? "") + "\n" + (memoItem?.content ?? ""))
    }

    func tappedDoneButton(textViewText: String) {
        if let memoItem = memoItem {
            // 既存メモの更新
            memoItemRepository.updateMemo(memoItem, text: textViewText) { [weak self] result in
                switch result {
                case .success(_): break
                case .failure(let error):
                    self?.view?.showErrorAlert(message: error.localizedDescription)
                }
            }
        } else {
            // 新規メモの作成
            memoItemRepository.createMemoItem(text: textViewText, uniqueId: nil) { [weak self] result in
                switch result {
                case .success(_): break
                case .failure(let error):
                   self?.view?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }

    @objc func didSaveMemo(_ notification: Notification) {
        view?.returnMemoList()
    }
}
