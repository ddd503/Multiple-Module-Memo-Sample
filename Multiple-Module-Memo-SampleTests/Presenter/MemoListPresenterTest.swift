//
//  MemoListPresenterTest.swift
//  Multiple-Module-Memo-SampleTests
//
//  Created by kawaharadai on 2020/03/01.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import XCTest
@testable import Multiple_Module_Memo_Sample

class MemoListPresenterTest: XCTestCase {

    var testExpectation = XCTestExpectation()

    required convenience init(presenterInputs: MemoListPresenterInputs) {
        self.init()
    }

    func test_memos_メモリスト更新時に適切なOutputが走るか() {
        testExpectation = expectation(description: "メモリスト更新時に適切なOutputが走るか")
        let memoItemRepository = MemoItemRepositoryMock()
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        var dummyMemos = [Memo]()
        (0..<20).forEach {
            let memo = Memo(uniqueId: "\($0)", title: "", content: "", editDate: nil)
            dummyMemos.append(memo)
        }

        presenterInputs.memos = dummyMemos

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_tableViewEditing_通常モードから編集モードへの切り替え時に適切なOutputが走るか() {
        testExpectation = expectation(description: "通常モードから編集モードへの切り替え時に適切なOutputが走るか")
        testExpectation.expectedFulfillmentCount = 2

        let memoItemRepository = MemoItemRepositoryMock()
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        XCTAssertFalse(presenterInputs.tableViewEditing)
        presenterInputs.tableViewEditing = true

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_tableViewEditing_編集モードから通常モードへの切り替え時に適切なOutputが走るか() {
        testExpectation = expectation(description: "編集モードから通常モードへの切り替え時に適切なOutputが走るか")
        testExpectation.expectedFulfillmentCount = 2

        let memoItemRepository = MemoItemRepositoryMock()
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.tableViewEditing = true
        presenterInputs.bind(view: self)

        XCTAssertTrue(presenterInputs.tableViewEditing)
        presenterInputs.tableViewEditing = false

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_tappedActionSheet_アクションシートタップ時に適切なOutputが走るか() {
        testExpectation = expectation(description: "アクションシートタップ時に適切なOutputが走るか")
        let memoItemRepository = MemoItemRepositoryMock()
        memoItemRepository.dummyDataBase = [MemoItemMock(uniqueId: "1"),
                                            MemoItemMock(uniqueId: "2")]
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        // キャンセル、全削除の順で流してみる（キャンセル時点で評価が走れば失敗する）
        presenterInputs.tappedActionSheet(AlertActionType.cancel.event)
        presenterInputs.tappedActionSheet(AlertActionType.allDelete.event)

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_viewDidLoad_画面表示時viewDidLoadに適切なOutputが走るか() {
        testExpectation = expectation(description: "画面表示時viewDidLoadに適切なOutputが走るか")
        // 2つの別々のOutputが完了することが成功条件
        testExpectation.expectedFulfillmentCount = 2

        let memoItemRepository = MemoItemRepositoryMock()
        memoItemRepository.dummyDataBase = [MemoItemMock(uniqueId: "1"),
                                            MemoItemMock(uniqueId: "2")]
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        presenterInputs.viewDidLoad()

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_viewWillAppear_画面表示時viewWillAppearに適切なOutputが走るか() {
        testExpectation = expectation(description: "画面表示時viewWillAppearに適切なOutputが走るか")

        let memoItemRepository = MemoItemRepositoryMock()
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        presenterInputs.viewWillAppear()

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_tappedUnderRightButton_右下ボタンタップ時に適切なOutputが走るか_編集モード時() {
        testExpectation = expectation(description: "右下ボタンタップ時に適切なOutputが走るか_編集モード時")

        let memoItemRepository = MemoItemRepositoryMock()
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        // bind前に編集モードにしておく
        presenterInputs.tableViewEditing = true
        presenterInputs.bind(view: self)

        presenterInputs.tappedUnderRightButton()

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_tappedUnderRightButton_右下ボタンタップ時に適切なOutputが走るか_非編集モード時() {
        testExpectation = expectation(description: "右下ボタンタップ時に適切なOutputが走るか_非編集モード時")

        let memoItemRepository = MemoItemRepositoryMock()
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        presenterInputs.tappedUnderRightButton()

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_deleteMemo_メモ削除動作時に適切なOutputが走るか() {
        testExpectation = expectation(description: "メモ削除動作時に適切なOutputが走るか")
        let memoItemRepository = MemoItemRepositoryMock()
        let dummyUniqueId1 = "1000"
        let dummyUniqueId2 = "2000"
        memoItemRepository.dummyDataBase = [MemoItemMock(uniqueId: dummyUniqueId1),
                                            MemoItemMock(uniqueId: dummyUniqueId2)]

        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        presenterInputs.deleteMemo(uniqueId: dummyUniqueId2)

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_didSaveMemo_メモ保存完了時に適切なOutputが走るか() {
        testExpectation = expectation(description: "メモ保存完了時に適切なOutputが走るか")
        let memoItemRepository = MemoItemRepositoryMock()
        memoItemRepository.dummyDataBase = [MemoItemMock(uniqueId: "2000")]
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        NotificationCenter.default.post(Notification(name: .NSManagedObjectContextDidSave))

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_didSelectItem_既存メモタップ時に適切なOutputが走るか() {
        testExpectation = expectation(description: "既存メモタップ時に適切なOutputが走るか")
        let memoItemRepository = MemoItemRepositoryMock()
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        let dummyUniqueId1 = "10"
        let dummyUniqueId2 = "20"
        presenterInputs.memos = [Memo(uniqueId: dummyUniqueId1,
                                      title: "",
                                      content: "",
                                      editDate: nil),
                                 Memo(uniqueId: dummyUniqueId2,
                                      title: "",
                                      content: "",
                                      editDate: nil)]
        presenterInputs.bind(view: self)

        presenterInputs.didSelectItem(indexPath: IndexPath(row: 1, section: 0))

        wait(for: [testExpectation], timeout: 1.0)
    }

    func test_showErrorAlert_異常系であるメモの削除に失敗した時に適切なOutputが走るか() {
        testExpectation = expectation(description: "異常系であるメモの削除に失敗した時に適切なOutputが走るか")
        let memoItemRepository = MemoItemRepositoryMock()
        memoItemRepository.isSuccessFunc = false

        let dummyUniqueId1 = "1000"
        let dummyUniqueId2 = "2000"
        memoItemRepository.dummyDataBase = [MemoItemMock(uniqueId: dummyUniqueId1),
                                            MemoItemMock(uniqueId: dummyUniqueId2)]
        let presenterInputs = MemoListPresenter(memoItemRepository: memoItemRepository)
        presenterInputs.bind(view: self)

        presenterInputs.deleteMemo(uniqueId: dummyUniqueId2)

        wait(for: [testExpectation], timeout: 1.0)
    }

}

extension MemoListPresenterTest: MemoListPresenterOutputs {
    func setupLayout() {
        switch testExpectation.description {
        case "画面表示時viewDidLoadに適切なOutputが走るか":
            XCTAssert(true)
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func updateMemoList(_ memos: [Memo]) {
        switch testExpectation.description {
        case "メモリスト更新時に適切なOutputが走るか":
            XCTAssertEqual(memos.count, 20)
            testExpectation.fulfill()
        case "アクションシートタップ時に適切なOutputが走るか":
            XCTAssertEqual(memos.count, 0)
            testExpectation.fulfill()
        case "画面表示時viewDidLoadに適切なOutputが走るか":
            XCTAssertEqual(memos.count, 2)
            testExpectation.fulfill()
        case "メモ削除動作時に適切なOutputが走るか":
            XCTAssertEqual(memos.count, 1)
            XCTAssertEqual(memos[0].uniqueId, "1000")
            testExpectation.fulfill()
        case "メモ保存完了時に適切なOutputが走るか":
            XCTAssertEqual(memos.count, 1)
            XCTAssertEqual(memos[0].uniqueId, "2000")
            testExpectation.fulfill()
        case "異常系であるメモの削除に失敗した時に適切なOutputが走るか":
            XCTFail("メモの削除処理が意図せず成功してしまった")
        default:
            XCTFail()
        }
    }

    func deselectRowIfNeeded() {
        switch testExpectation.description {
        case "画面表示時viewWillAppearに適切なOutputが走るか":
            XCTAssert(true)
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func transitionCreateMemo() {
        switch testExpectation.description {
        case "右下ボタンタップ時に適切なOutputが走るか_非編集モード時":
            XCTAssert(true)
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func transitionDetailMemo(memo: Memo) {
        switch testExpectation.description {
        case "既存メモタップ時に適切なOutputが走るか":
            XCTAssertEqual(memo.uniqueId, "20")
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func updateTableViewIsEditing(_ isEditing: Bool) {
        switch testExpectation.description {
        case "通常モードから編集モードへの切り替え時に適切なOutputが走るか":
            XCTAssertTrue(isEditing)
            testExpectation.fulfill()
        case "編集モードから通常モードへの切り替え時に適切なOutputが走るか":
            XCTAssertFalse(isEditing)
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func updateButtonTitle(title: String) {
        switch testExpectation.description {
        case "通常モードから編集モードへの切り替え時に適切なOutputが走るか":
            XCTAssertEqual(title, "すべて削除")
            testExpectation.fulfill()
        case "編集モードから通常モードへの切り替え時に適切なOutputが走るか":
            XCTAssertEqual(title, "メモ追加")
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func showAllDeleteActionSheet() {
        switch testExpectation.description {
        case "右下ボタンタップ時に適切なOutputが走るか_編集モード時":
            XCTAssert(true)
            testExpectation.fulfill()
        default:
            XCTFail()
        }
    }

    func showErrorAlert(message: String?) {
        switch testExpectation.description {
        case "アクションシートタップ時に正常なOutputが走るか":
            XCTFail(message ?? "")
            testExpectation.fulfill()
        case "メモ削除動作時に適切なOutputが走るか":
            XCTFail(message ?? "")
            testExpectation.fulfill()
        case "異常系であるメモの削除に失敗した時に適切なOutputが走るか":
            XCTAssert(true)
            testExpectation.fulfill()
        default:
            XCTFail(message ?? "")
        }
    }
}
