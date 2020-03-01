//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation
import Data

protocol MemoListPresenterInputs {
    var memos: [Memo] { get set }
    var tableViewEditing: Bool { get set }
    var tappedActionSheet: (AlertEvent) -> () { get set }
    func bind(view: MemoListPresenterOutputs)
    func viewDidLoad()
    func viewWillAppear()
    func tappedUnderRightButton()
    func deleteMemo(uniqueId: String)
    func didSaveMemo(_ notification: Notification)
    func didSelectItem(indexPath: IndexPath)
}

protocol MemoListPresenterOutputs: class {
    init(presenterInputs: MemoListPresenterInputs)
    func setupLayout()
    func updateMemoList(_ memos: [Memo])
    func deselectRowIfNeeded()
    func transitionCreateMemo()
    func transitionDetailMemo(memo: Memo)
    func updateTableViewIsEditing(_ isEditing: Bool)
    func updateButtonTitle(title: String)
    func showAllDeleteActionSheet()
    func showErrorAlert(message: String?)
}

final class MemoListPresenter: MemoListPresenterInputs {

    weak var view: MemoListPresenterOutputs?
    let memoItemRepository: MemoItemRepository

    var memos: [Memo] = [] {
        didSet {
            // データソースが更新された通知
            view?.updateMemoList(memos)
        }
    }

    var tableViewEditing = false {
        didSet {
            // 編集モード切り替え
            view?.updateTableViewIsEditing(tableViewEditing)
            view?.updateButtonTitle(title: tableViewEditing ? "全て削除" : "メモ追加")
        }
    }

    // タップ時の結果を注入（AlertEventが渡ってくる）
    lazy var tappedActionSheet: (AlertEvent) -> () = { [weak self] event in
        guard let self = self else { return }
        switch event.actionType {
        case .allDelete:
            self.memoItemRepository.deleteAllMemoItems(entityName: "MemoItem") { result in
                switch result {
                case .success(_):
                    self.memoItemRepository.readAllMemoItems { result in
                        switch result {
                        case .success(let memoItems):
                            self.memos = Translater.memoItemsToMemos(memoItems: memoItems)
                        case .failure(let error):
                            self.view?.showErrorAlert(message: error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    self.view?.showErrorAlert(message: error.localizedDescription)
                }
            }
        case .cancel: break
        }
    }

    init(memoItemRepository: MemoItemRepository) {
        self.memoItemRepository = memoItemRepository
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSaveMemo(_:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
    }

    func bind(view: MemoListPresenterOutputs) {
        self.view = view
    }

    func viewDidLoad() {
        view?.setupLayout()
        memoItemRepository.readAllMemoItems { [weak self] result in
            switch result {
            case .success(let memoItems):
                self?.memos = Translater.memoItemsToMemos(memoItems: memoItems)
            case .failure(let error):
                self?.view?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    func viewWillAppear() {
        view?.deselectRowIfNeeded()
    }

    func tappedUnderRightButton() {
        if tableViewEditing {
            view?.showAllDeleteActionSheet()
        } else {
            view?.transitionCreateMemo()
        }
    }

    func deleteMemo(uniqueId: String) {
        memoItemRepository.deleteMemoItem(at: uniqueId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.memoItemRepository.readAllMemoItems { result in
                    switch result {
                    case .success(let memoItems):
                        self.memos = Translater.memoItemsToMemos(memoItems: memoItems)
                    case .failure(let error):
                        self.view?.showErrorAlert(message: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.view?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    @objc func didSaveMemo(_ notification: Notification) {
        memoItemRepository.readAllMemoItems { [weak self] result in
            switch result {
            case .success(let memoItems):
                self?.memos = Translater.memoItemsToMemos(memoItems: memoItems)
            case .failure(_): break
            }
        }
    }

    func didSelectItem(indexPath: IndexPath) {
        view?.transitionDetailMemo(memo: memos[indexPath.row])
    }
}
