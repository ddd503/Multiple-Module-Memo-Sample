//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

protocol MemoListPresenterInputs {
    var memoItemRepository: MemoItemRepository { get }
    var tableViewEditing: Bool { get set }
    var memoItems: [Memo] { get set }
    var showActionSheet: (AlertEvent) -> () { get set }
    func tappedUnderRightButton()
    func deleteMemo(uniqueId: String)
    func didSaveMemo(_ notification: Notification)
    func didSelectItem(indexPath: IndexPath)
}

protocol MemoListPresenterOutputs: class {
    init(presenterInput: MemoListPresenterInputs)
    func updateMemoList()
    func transitionCreateMemo()
    func transitionDetailMemo(memo: Memo)
    func updateButtonTitle(title: String)
    func showErrorAlert(message: String?)
}

final class MemoListPresenter: MemoListPresenterInputs {

    weak var output: MemoListPresenterOutputs?
    let memoItemRepository: MemoItemRepository
    var showActionSheet: (AlertEvent) -> ()
    var tableViewEditing = false {
        didSet {
            // 編集モード切り替え
            output?.updateButtonTitle(title: tableViewEditing ? "全て削除" : "メモ追加")
        }
    }
    var memoItems: [Memo] {
        didSet {
            // データソースが更新された通知
            output?.updateMemoList()
        }
    }

    init(memoItemRepository: MemoItemRepository, memoItems: [Memo], showActionSheet: @escaping (AlertEvent) -> ()) {
        self.memoItemRepository = memoItemRepository
        self.memoItems = memoItems
        self.showActionSheet = showActionSheet
        NotificationCenter.default.addObserver(self,
                selector: #selector(didSaveMemo(_:)),
                name: .NSManagedObjectContextDidSave,
                object: nil)
    }

    func tappedUnderRightButton() {
        if tableViewEditing {
            // タップ時の結果を注入（タップ時はAlertEventが渡ってくる）
            showActionSheet = { [weak self] event in
                guard let self = self else { return }
                switch event.actionType {
                case .allDelete:
                    self.memoItemRepository.deleteAllMemos(entityName: "Memo") { result in
                        switch result {
                        case .success(_):
                            self.memoItemRepository.readAllMemos { result in
                                switch result {
                                case .success(let memos):
                                    self.memoItems = memos
                                case .failure(let error):
                                    self.output?.showErrorAlert(message: error.localizedDescription)
                                }
                            }
                        case .failure(let error):
                            self.output?.showErrorAlert(message: error.localizedDescription)
                        }
                    }
                case .cancel: break
                }
            }
        } else {
            output?.transitionCreateMemo()
        }
    }

    func deleteMemo(uniqueId: String) {
        memoItemRepository.deleteMemo(at: uniqueId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.memoItemRepository.readAllMemos { result in
                    switch result {
                    case .success(let memos):
                        self.memoItems = memos
                    case .failure(let error):
                        self.output?.showErrorAlert(message: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.output?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    @objc func didSaveMemo(_ notification: Notification) {
        memoItemRepository.readAllMemos { result in
            switch result {
            case .success(let memos):
                self.memoItems = memos
            case .failure(_): break
            }
        }
    }

    func didSelectItem(indexPath: IndexPath) {
        output?.transitionDetailMemo(memo: memoItems[indexPath.row])
    }
}