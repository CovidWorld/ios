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
//  APIRequests.swift
//  Covid
//
//  Created by Boris Kolozsi on 12/03/2020.
//

import Foundation
import SwiftyUserDefaults

struct RegisterProfileRequestData: Codable {
    let deviceId: String
    let locale: String
    let pushToken: String?
    let phoneNumber: String?
    
    init(deviceId: String = Defaults.deviceId, locale: String = (Locale.current.regionCode ?? "SK"), pushToken: String? = Defaults.pushToken, phoneNumber: String? = Defaults.phoneNumber) {
        self.deviceId = deviceId
        self.locale = locale
        self.pushToken = pushToken
        self.phoneNumber = phoneNumber
    }
}

struct BasicRequestData: Codable {
    let deviceId: String
    let profileId: Int
    
    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
    }
}

struct QuarantineRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let duration: String
    let mfaToken: String
    
    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, duration: String? = nil, mfaToken: String? = Defaults.mfaToken) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.mfaToken = mfaToken ?? ""
        
        let quarantineDuration = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?["quarantineDuration"].stringValue ?? "14"
        
        guard let date = Defaults.quarantineStart else {
            self.duration = quarantineDuration
            return
        }
        let currentCalendar = Calendar.current
        let currentDate = Date()

        let days = currentCalendar.dateComponents([.day], from: date, to: currentDate)
        if let remainingDays = Int(quarantineDuration), let days = days.day {
            self.duration = String(remainingDays - days)
        } else {
            self.duration = quarantineDuration
        }
    }
}

struct MFATokenPhoneRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let mfaToken: String
    
    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, mfaToken: String? = Defaults.mfaToken) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.mfaToken = mfaToken ?? ""
    }
}

struct AreaExitRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let latitude: Double
    let longitude: Double
    let accuracy: Int
    let recordTimestamp: Int
    
    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, latitude: Double, longitude: Double, accuracy: Int) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.recordTimestamp = Int(Date().timeIntervalSince1970)
    }
}

struct LocationsRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let locations: [Location]
    
    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, locations: [Location]) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.locations = locations
    }
}

struct UploadConnectionsRequestData: Codable {
    let sourceDeviceId: String
    let sourceProfileId: Int
    let connections: [Connection]
    
    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, connections: [Connection]) {
        sourceDeviceId = deviceId
        sourceProfileId = profileId ?? 0
        self.connections = connections
    }
}

struct Location: Codable {
    let recordTimestamp: Int
    let latitude: Double
    let longitude: Double
    let accuracy : Double
}

struct Connection: Codable, Hashable, Equatable {
    let seenProfileId: Int
    let timestamp: Int
    let duration: String
    let latitude: Double
    let longitude: Double
    let accuracy : Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(seenProfileId)
    }
    
    static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.seenProfileId == rhs.seenProfileId
    }
}

struct Position: Codable {
    let profileId: String
    let deviceId: String
    let latitude: Double
    let longitude: Double
    let accuracy : Double
}
