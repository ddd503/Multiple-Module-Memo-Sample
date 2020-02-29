//
// Created by kawaharadai on 2020/02/25.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

protocol MemoListPresenterInputs {
    var memoItemRepository: MemoItemRepository { get }
    var memoItems: [MemoInfo] { get set }
    var tappedActionSheet: (AlertEvent) -> () { get set }
    func bind(view: MemoListPresenterOutputs)
    func viewDidLoad()
    func viewWillAppear()
    func tappedUnderRightButton()
    func deleteMemo(uniqueId: String)
    func didChangeTableViewEditing(_ editing: Bool)
    func didSaveMemo(_ notification: Notification)
    func didSelectItem(indexPath: IndexPath)
}

protocol MemoListPresenterOutputs: class {
    init(presenterInputs: MemoListPresenterInputs)
    func setupLayout()
    func updateMemoList(_ memoItems: [MemoInfo])
    func deselectRowIfNeeded()
    func transitionCreateMemo()
    func transitionDetailMemo(memo: MemoInfo)
    func updateTableViewIsEditing(_ isEditing: Bool)
    func updateButtonTitle(title: String)
    func showAllDeleteActionSheet()
    func showErrorAlert(message: String?)
}

final class MemoListPresenter: MemoListPresenterInputs {

    weak var view: MemoListPresenterOutputs?
    let memoItemRepository: MemoItemRepository

    var tableViewEditing = false {
        didSet {
            // 編集モード切り替え
            view?.updateTableViewIsEditing(tableViewEditing)
            view?.updateButtonTitle(title: tableViewEditing ? "全て削除" : "メモ追加")
        }
    }

    var memoItems: [MemoInfo] = [] {
        didSet {
            // データソースが更新された通知
            view?.updateMemoList(memoItems)
        }
    }

    // タップ時の結果を注入（AlertEventが渡ってくる）
    lazy var tappedActionSheet: (AlertEvent) -> () = { [weak self] event in
        guard let self = self else { return }
        switch event.actionType {
        case .allDelete:
            self.memoItemRepository.deleteAllMemos(entityName: "Memo") { result in
                switch result {
                case .success(_):
                    self.memoItemRepository.readAllMemos { result in
                        switch result {
                        case .success(let memos):
                            self.memoItems = Translater.memosToMemoInfos(memos: memos)
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
        memoItemRepository.readAllMemos { [weak self] result in
            switch result {
            case .success(let memos):
                self?.memoItems = Translater.memosToMemoInfos(memos: memos)
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
        memoItemRepository.deleteMemo(at: uniqueId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.memoItemRepository.readAllMemos { result in
                    switch result {
                    case .success(let memos):
                        self.memoItems = Translater.memosToMemoInfos(memos: memos)
                    case .failure(let error):
                        self.view?.showErrorAlert(message: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.view?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    func didChangeTableViewEditing(_ editing: Bool) {
        tableViewEditing = editing
    }

    @objc func didSaveMemo(_ notification: Notification) {
        memoItemRepository.readAllMemos { [weak self] result in
            switch result {
            case .success(let memos):
                self?.memoItems = Translater.memosToMemoInfos(memos: memos)
            case .failure(_): break
            }
        }
    }

    func didSelectItem(indexPath: IndexPath) {
        view?.transitionDetailMemo(memo: memoItems[indexPath.row])
    }
}
