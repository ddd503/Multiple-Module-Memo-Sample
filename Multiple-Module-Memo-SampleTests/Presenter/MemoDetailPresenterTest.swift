//
//  MemoDetailPresenterTest.swift
//  Multiple-Module-Memo-SampleTests
//
//  Created by kawaharadai on 2020/03/01.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import XCTest
@testable import Multiple_Module_Memo_Sample

class MemoDetailPresenterTest: XCTestCase {

    var testExpectation = XCTestExpectation()
    var memoItemRepository = MemoItemRepositoryMock()

    required convenience init(presenterInputs: MemoDetailPresenterInputs) {
        self.init()
    }

    func test_viewDidLoad_画面表示時に適切なOutputが走るか_新規メモ作成時() {
        testExpectation = expectation(description: "画面表示時に適切なOutputが走るか_新規メモ作成時")
        testExpectation.expectedFulfillmentCount = 3

        memoItemRepository = MemoItemRepositoryMock()
        let presenterInputs = MemoDetailPresenter(memoItemRepository: memoItemRepository, memo: nil)
        presenterInputs.bind(view: self)

        presenterInputs.viewDidLoad()

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_viewDidLoad_画面表示時に適切なOutputが走るか_既存メモ編集時() {
        testExpectation = expectation(description: "画面表示時に適切なOutputが走るか_既存メモ編集時")
        testExpectation.expectedFulfillmentCount = 3

        memoItemRepository = MemoItemRepositoryMock()
        let memo = Memo(uniqueId: "1000", title: "title1", content: "content1", editDate: nil)
        let presenterInputs = MemoDetailPresenter(memoItemRepository: memoItemRepository, memo: memo)
        presenterInputs.bind(view: self)

        presenterInputs.viewDidLoad()

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_tappedDoneButton_didSaveMemo_Doneボタンタップ時に適切なOutputが走るか_新規メモ作成時() {
        testExpectation = expectation(description: "Doneボタンタップ時に適切なOutputが走るか_新規メモ作成時")
        memoItemRepository = MemoItemRepositoryMock()

        let presenterInputs = MemoDetailPresenter(memoItemRepository: memoItemRepository, memo: nil)
        presenterInputs.bind(view: self)

        presenterInputs.tappedDoneButton(textViewText: "title2\ncontent2")

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_tappedDoneButton_didSaveMemo_Doneボタンタップ時に適切なOutputが走るか_既存メモ編集時() {
        testExpectation = expectation(description: "Doneボタンタップ時に適切なOutputが走るか_既存メモ編集時")
        memoItemRepository = MemoItemRepositoryMock()

        let memo = Memo(uniqueId: "300", title: "title1", content: "content1", editDate: nil)
        let memoItem = MemoItemMock(uniqueId: memo.uniqueId, title: memo.title,
                                    content: memo.content, editDate: memo.editDate)
        memoItemRepository.dummyDataBase.append(memoItem)
        let presenterInputs = MemoDetailPresenter(memoItemRepository: memoItemRepository, memo: memo)
        presenterInputs.bind(view: self)

        presenterInputs.tappedDoneButton(textViewText: "title3\ncontent3\ncontent4")

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_didChangeTextView_TextView編集時に適切なOutputが走るか_文字数が0から増えた時() {
        testExpectation = expectation(description: "TextView編集時に適切なOutputが走るか_文字数が0から増えた時")
        memoItemRepository = MemoItemRepositoryMock()

        let presenterInputs = MemoDetailPresenter(memoItemRepository: memoItemRepository, memo: nil)
        presenterInputs.bind(view: self)

        presenterInputs.didChangeTextView("t")

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_didChangeTextView_TextView編集時に適切なOutputが走るか_文字数が0になった時() {
        testExpectation = expectation(description: "TextView編集時に適切なOutputが走るか_文字数が0になった時")
        memoItemRepository = MemoItemRepositoryMock()

        let presenterInputs = MemoDetailPresenter(memoItemRepository: memoItemRepository, memo: nil)
        presenterInputs.bind(view: self)

        presenterInputs.didChangeTextView("")

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_showErrorAlert_異常系である新規メモの作成に失敗した時に適切なOutputが走るか() {
        testExpectation = expectation(description: "異常系である新規メモの作成に失敗した時に適切なOutputが走るか")
        memoItemRepository = MemoItemRepositoryMock()
        memoItemRepository.isSuccessFunc = false

        let presenterInputs = MemoDetailPresenter(memoItemRepository: memoItemRepository, memo: nil)
        presenterInputs.bind(view: self)

        presenterInputs.tappedDoneButton(textViewText: "title2\ncontent2")

        wait(for: [testExpectation], timeout: 1.0)
    }

}

extension MemoDetailPresenterTest: MemoDetailPresenterOutputs {
    func setupText(_ initialText: String?) {
        switch testExpectation.description {
        case "画面表示時に適切なOutputが走るか_新規メモ作成時":
            XCTAssertEqual(initialText, "")
            testExpectation.fulfill()
        case "画面表示時に適切なOutputが走るか_既存メモ編集時":
            XCTAssertEqual(initialText, "title1\ncontent1")
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func setupTitle(_ title: String) {
        switch testExpectation.description {
        case "画面表示時に適切なOutputが走るか_新規メモ作成時":
            XCTAssertEqual(title, "新規メモ")
            testExpectation.fulfill()
        case "画面表示時に適切なOutputが走るか_既存メモ編集時":
            XCTAssertEqual(title, "title1")
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func setupDoneButton() {
        switch testExpectation.description {
        case "画面表示時に適切なOutputが走るか_新規メモ作成時":
            XCTAssert(true)
            testExpectation.fulfill()
        case "画面表示時に適切なOutputが走るか_既存メモ編集時":
            XCTAssert(true)
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func returnMemoList() {
        switch testExpectation.description {
        case "Doneボタンタップ時に適切なOutputが走るか_新規メモ作成時":
            XCTAssertEqual(memoItemRepository.dummyDataBase.count, 1)
            let memoItem = memoItemRepository.dummyDataBase[0]
            XCTAssertEqual(memoItem.uniqueId, "1")
            XCTAssertEqual(memoItem.title, "title2")
            XCTAssertEqual(memoItem.content, "content2")
            testExpectation.fulfill()
        case "Doneボタンタップ時に適切なOutputが走るか_既存メモ編集時":
            XCTAssertEqual(memoItemRepository.dummyDataBase.count, 1)
            let memoItem = memoItemRepository.dummyDataBase[0]
            XCTAssertEqual(memoItem.uniqueId, "300")
            XCTAssertEqual(memoItem.title, "title3")
            XCTAssertEqual(memoItem.content, "content3\ncontent4")
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func showErrorAlert(message: String?) {
        switch testExpectation.description {
        case "Doneボタンタップ時に適切なOutputが走るか_新規メモ作成時":
            XCTFail(message ?? "")
            testExpectation.fulfill()
        case "Doneボタンタップ時に適切なOutputが走るか_既存メモ編集時":
            XCTFail(message ?? "")
            testExpectation.fulfill()
        case "異常系である新規メモの作成に失敗した時に適切なOutputが走るか":
            XCTAssert(true)
            testExpectation.fulfill()
        default:
            XCTFail(message ?? "")
        }
    }

    func updateDoneButtonState(isEnabled: Bool) {
        switch testExpectation.description {
        case "TextView編集時に適切なOutputが走るか_文字数が0から増えた時":
            XCTAssertTrue(isEnabled)
            testExpectation.fulfill()
        case "TextView編集時に適切なOutputが走るか_文字数が0になった時":
            XCTAssertFalse(isEnabled)
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }
}
