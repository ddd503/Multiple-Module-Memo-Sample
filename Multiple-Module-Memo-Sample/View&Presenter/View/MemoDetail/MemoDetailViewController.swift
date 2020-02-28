//
//  MemoDetailViewController.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/26.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

final class MemoDetailViewController: UIViewController {
    
    @IBOutlet weak private var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
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
        textView.text = initialText
        presenterInputs.didChangeTextView(textView.text)
    }

    func setupTitle(_ title: String) {
        self.title = title
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

    func updateDoneButtonState(isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.doneButtonItem.isEnabled = isEnabled
        }
    }
}

extension MemoDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.presenterInputs.didChangeTextView(textView.text)
        }
        return true
    }
}
