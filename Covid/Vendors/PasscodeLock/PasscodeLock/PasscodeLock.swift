//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

class PasscodeLock: PasscodeLockType {

    weak var delegate: PasscodeLockTypeDelegate?
    let configuration: PasscodeLockConfigurationType

    var state: PasscodeLockStateType {
        lockState
    }

    private var lockState: PasscodeLockStateType
    private var passcode = [String]()

    init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {

        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")

        self.lockState = state
        self.configuration = configuration
    }

    func addSign(sign: String) {

        passcode.append(sign)
        delegate?.passcodeLock(lock: self, addedSignAtIndex: passcode.count - 1)

        if passcode.count >= configuration.passcodeLength {

            lockState.acceptPasscode(passcode: passcode, fromLock: self)
            passcode.removeAll(keepingCapacity: true)
        }
    }

    func removeSign() {

        guard passcode.count > 0 else { return }

        passcode.removeLast()
        delegate?.passcodeLock(lock: self, removedSignAtIndex: passcode.count)
    }

    func changeStateTo(state: PasscodeLockStateType) {
        DispatchQueue.main.async {
            self.lockState = state
            self.delegate?.passcodeLockDidChangeState(lock: self)
        }
    }
}
