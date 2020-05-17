//
//  PasscodeLockConfigurationType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

protocol PasscodeLockConfigurationType {

    var passcodeLength: Int {get}
    var maximumIncorrectPasscodeAttempts: Int {get}
}
