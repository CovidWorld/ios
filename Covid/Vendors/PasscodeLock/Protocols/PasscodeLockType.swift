//
//  PasscodeLockType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

protocol PasscodeLockType {

    var delegate: PasscodeLockTypeDelegate? {get set}
    var configuration: PasscodeLockConfigurationType {get}
    var state: PasscodeLockStateType {get}

    func addSign(sign: String)
    func removeSign()
    func changeStateTo(state: PasscodeLockStateType)
}

protocol PasscodeLockTypeDelegate: class {

    func passcodeLockDidSucceed(lock: PasscodeLockType, passcode: [String])
    func passcodeLockDidFail(lock: PasscodeLockType)
    func passcodeLockDidChangeState(lock: PasscodeLockType)
    func passcodeLock(lock: PasscodeLockType, addedSignAtIndex index: Int)
    func passcodeLock(lock: PasscodeLockType, removedSignAtIndex index: Int)
}
