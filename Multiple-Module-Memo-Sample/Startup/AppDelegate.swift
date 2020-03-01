//
//  AppDelegate.swift
//  Multiple-Module-Memo-Sample
//
//  Created by kawaharadai on 2020/02/23.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit
import Data

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        let startupVC = ViewControllerBuilder.buildMemoListVC()
        let navigationController = UINavigationController(rootViewController: startupVC)
        window.rootViewController = navigationController
        self.window = window
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let result = MemoItemDataStoreImpl().save(context: CoreDataManager.shared.persistentContainer.viewContext)
        switch result {
        case .success(_): break
        case .failure(let error):
            print("Error: applicationWillTerminate_\(error.localizedDescription)")
        }
    }
}
