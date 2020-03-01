//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation
import Data

protocol MemoDetailPresenterInputs {
    func bind(view: MemoDetailPresenterOutputs)
    func viewDidLoad()
    func tappedDoneButton(textViewText: String)
    func didSaveMemo(_ notification: Notification)
    func didChangeTextView(_ text: String)
}

protocol MemoDetailPresenterOutputs: class {
    init(presenterInputs: MemoDetailPresenterInputs)
    func setupText(_ initialText: String?)
    func setupTitle(_ title: String)
    func setupDoneButton()
    func returnMemoList()
    func showErrorAlert(message: String?)
    func updateDoneButtonState(isEnabled: Bool)
}

final class MemoDetailPresenter: MemoDetailPresenterInputs {

    weak var view: MemoDetailPresenterOutputs?
    let memoItemRepository: MemoItemRepository
    let memo: Memo?

    // memoItemがnilの場合、新規作成、ある場合は既存メモの編集
    init(memoItemRepository: MemoItemRepository, memo: Memo?) {
        self.memoItemRepository = memoItemRepository
        self.memo = memo
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSaveMemo(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
    }

    func bind(view: MemoDetailPresenterOutputs) {
        self.view = view
    }

    func viewDidLoad() {
        let initialText = (memo == nil) ? "" : (memo?.title ?? "") + "\n" + (memo?.content ?? "")
        view?.setupText(initialText)
        let title = memo?.title ?? "新規メモ"
        view?.setupTitle(title)
        view?.setupDoneButton()
    }

    func tappedDoneButton(textViewText: String) {
        if let memo = memo {
            // 既存メモの更新
            memoItemRepository.updateMemoItem(uniqueId: memo.uniqueId, text: textViewText) { [weak self] result in
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

    func didChangeTextView(_ text: String) {
        view?.updateDoneButtonState(isEnabled: !text.isEmpty)
    }
}
