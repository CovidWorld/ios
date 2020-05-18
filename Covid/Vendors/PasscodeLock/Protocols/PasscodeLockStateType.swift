//
//  PasscodeLockStateType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

protocol PasscodeLockStateType {

    var title: String {get}
    var description: String {get}
    var isCancellableAction: Bool {get}

    mutating func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType)
}
