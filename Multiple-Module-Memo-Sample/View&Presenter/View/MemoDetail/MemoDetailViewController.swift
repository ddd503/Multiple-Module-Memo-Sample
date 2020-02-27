//
//  MemoDetailViewController.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/26.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

final class MemoDetailViewController: UIViewController {
    
    @IBOutlet weak private var textView: UITextView!
    private var doneButtonItem: UIBarButtonItem!
    
    let presenterInputs: MemoDetailPresenterInputs
    
    init(presenterInputs: MemoDetailPresenterInputs) {
        self.presenterInputs = presenterInputs
        super.init(nibName: "MemoDetailViewController", bundle: .main)
        self.presenterInputs.bind(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenterInputs.viewDidLoad()
    }
    
    @objc func tappedDoneButton(sender: UIButton) {
        presenterInputs.tappedDoneButton(textViewText: textView.text)
    }
}

extension MemoDetailViewController: MemoDetailPresenterOutputs {
    func setupText(_ initialText: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.textView.text = initialText
        }
    }

    func setupDoneButton() {
        doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(tappedDoneButton(sender:)))
        navigationItem.rightBarButtonItem = doneButtonItem
        textView.becomeFirstResponder()
    }
    
    func returnMemoList() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(message: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.showNormalErrorAlert(message: message)
        }
    }
}
