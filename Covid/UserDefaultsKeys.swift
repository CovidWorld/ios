/*-
* Copyright (c) 2020 Sygic
*
 * Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
 * The above copyright notice and this permission notice shall be included in
* copies or substantial portions of the Software.
*
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*/

//
//  UserDefaultsKeys.swift
//  Covid
//
//  Created by Boris Kolozsi on 15/03/2020.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var didRunApp: DefaultsKey<Bool> { return .init("didRunApp", defaultValue: false) }
    var didShowForeignAlert: DefaultsKey<Bool> { return .init("didShowForeignAlert", defaultValue: false) }
    
    var deviceId: DefaultsKey<String> { return .init("deviceId", defaultValue: "") }
    var profileId: DefaultsKey<Int?> { return .init("profileId") }
    var pushToken: DefaultsKey<String?> { return .init("pushToken") }
    var tempPhoneNumber: DefaultsKey<String?> { return .init("tempPhoneNumber") }
    var phoneNumber: DefaultsKey<String?> { return .init("phoneNumber") }
    var mfaToken: DefaultsKey<String?> { return .init("mfaToken") }
    
    var quarantineLatitude: DefaultsKey<Double?> { return .init("quarantineLatitude") }
    var quarantineLongitude: DefaultsKey<Double?> { return .init("quarantineLongitude") }
    var quarantineAddress: DefaultsKey<String?> { return .init("quarantineAddress") }
    var quarantineCity: DefaultsKey<String?> { return .init("quarantineCity") }
    var quarantineStart: DefaultsKey<Date?> { return .init("quarantineStart") }
    var quarantineEnd: DefaultsKey<Date?> { return .init("quarantineEnd") }
    var quarantineActive: DefaultsKey<Bool> { return .init("quarantineActive", defaultValue: false) }
    
    var lastLocationUpdate: DefaultsKey<Double?> { return .init("lastLocationUpdate") }
    var lastConnectionsUpdate: DefaultsKey<Double?> { return .init("lastConnectionsUpdate") }
    
    var lastQuarantineUpdate: DefaultsKey<Double?> { return .init("lastQuarantineUpdate") }
}
