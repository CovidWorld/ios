//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

let PasscodeLockIncorrectPasscodeNotification = "passcode.lock.incorrect.passcode.notification"

struct EnterPasscodeState: PasscodeLockStateType {

    let title: String
    let description: String
    let isCancellableAction: Bool

    private var inccorectPasscodeAttempts = 0
    private var isNotificationSent = false

    init(allowCancellation: Bool = false) {

        isCancellableAction = allowCancellation
        title = localizedStringFor(key: "PasscodeLockEnterTitle", comment: "Enter passcode title")
        description = localizedStringFor(key: "PasscodeLockEnterDescription", comment: "Enter passcode description")
    }

    mutating func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType) {
        lock.delegate?.passcodeLockDidSucceed(lock: lock, passcode: passcode)
    }

    private mutating func postNotification() {

        guard !isNotificationSent else { return }

        let center = NotificationCenter.default

        center.post(name: NSNotification.Name(rawValue: PasscodeLockIncorrectPasscodeNotification), object: nil)

        isNotificationSent = true
    }
}
