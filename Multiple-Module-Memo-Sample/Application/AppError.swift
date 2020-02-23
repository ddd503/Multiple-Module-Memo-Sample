//
// Created by kawaharadai on 2020/02/23.
// Copyright (c) 2020 kawaharadai. All rights reserved.
//

import Foundation

enum CoreDataError: Error {
    case failedCreateEntity
    case failedGetManagedObject
    case failedPrepareRequest
    case failedFetchRequest
    case failedExecuteStoreRequest
}