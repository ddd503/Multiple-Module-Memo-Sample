//
//  MemoListViewController.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/26.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

final class MemoListViewController: UIViewController {

    @IBOutlet weak private var underRightButton: UIButton!
    @IBOutlet weak private var countLabel: UILabel!
    @IBOutlet weak private var emptyLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(MemoInfoCell.nib(), forCellReuseIdentifier: MemoInfoCell.identifier)
            tableView.tableFooterView = UIView()
        }
    }

    let presenterInputs: MemoListPresenterInputs

    init(presenterInputs: MemoListPresenterInputs) {
        self.presenterInputs = presenterInputs
        super.init(nibName: "MemoListViewController", bundle: .main)
        self.presenterInputs.bind(view: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenterInputs.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenterInputs.viewWillAppear()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        presenterInputs.didChangeTableViewEditing(editing)
    }

    @IBAction func tappedUnderRightButton(sender: UIButton) {
        presenterInputs.tappedUnderRightButton()
    }
}

extension MemoListViewController: MemoListPresenterOutputs {
    func setupLayout() {
        title = "メモ"
        navigationItem.rightBarButtonItem = editButtonItem
    }

    func updateMemoList(_ memoItems: [MemoInfo]) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.countLabel.text = memoItems.isEmpty ? "メモなし" : "\(memoItems.count)件のメモ"
            self?.emptyLabel.isHidden = !memoItems.isEmpty
            if memoItems.isEmpty {
                self?.setEditing(false, animated: true)
            }
        }
    }

    func deselectRowIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            if let indexPathForSelectedRow = self?.tableView.indexPathForSelectedRow {
                self?.tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
            }
        }
    }

    func transitionCreateMemo() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.pushViewController(ViewControllerBuilder.buildMemoDetailVC(), animated: true)
        }
    }

    func transitionDetailMemo(memo: MemoInfo) {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.pushViewController(ViewControllerBuilder.buildMemoDetailVC(memo: memo), animated: true)
        }
    }

    func updateTableViewIsEditing(_ isEditing: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.isEditing = isEditing
        }
    }

    func updateButtonTitle(title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.underRightButton.setTitle(title, for: .normal)
        }
    }

    func showAllDeleteActionSheet() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showAlert(style: .actionSheet,
                           actions: [AlertActionType.allDelete.event, AlertActionType.cancel.event],
                           handler: self.presenterInputs.tappedActionSheet)
        }
    }
    
    func showErrorAlert(message: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.showNormalErrorAlert(message: message)
        }
    }
}

extension MemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenterInputs.memoItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemoInfoCell.identifier, for: indexPath) as! MemoInfoCell
        cell.setInfo(memo: presenterInputs.memoItems[indexPath.row])
        return cell
    }
}

extension MemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenterInputs.didSelectItem(indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let uniqueId = presenterInputs.memoItems[indexPath.row].uniqueId
            presenterInputs.deleteMemo(uniqueId: uniqueId)
        default: break
        }
    }
}
