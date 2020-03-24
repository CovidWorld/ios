//
//  UserDefaultsKeys.swift
//  Covid
//
//  Created by Boris Kolozsi on 15/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
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
