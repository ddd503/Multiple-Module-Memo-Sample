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
            tableView.register(MemoInfoCell.nib(), forCellReuseIdentifier: MemoInfoCell.identifier)
            tableView.tableFooterView = UIView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func tappedUnderRightButton(sender: UIButton) {}
}
