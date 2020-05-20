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

    init(deviceId: String = Defaults.deviceId,
         locale: String = (Locale.current.regionCode ?? "SK"),
         pushToken: String? = Defaults.FCMToken) {
        self.deviceId = deviceId
        self.locale = locale
        self.pushToken = pushToken
    }
}

struct BasicRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let covidPass: String

    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, covidPass: String? = Defaults.covidPass) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.covidPass = covidPass ?? ""
    }
}

struct BasicWithNonceRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let covidPass: String
    let nonce: String

    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, covidPass: String? = Defaults.covidPass, nonce: String) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.covidPass = covidPass ?? ""
        self.nonce = nonce
    }
}

struct QuarantineRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let startDate: String
    let endDate: String
    let covidPass: String

    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, startDate: String, endDate: String, covidPass: String) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.startDate = startDate
        self.endDate = endDate
        self.covidPass = covidPass
    }
}

struct AreaExitRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let severity: Int
    let recordTimestamp: Int

    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, severity: Int) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.severity = severity
        self.recordTimestamp = Int(Date().timeIntervalSince1970)
    }
}

struct PresenceCheckRequestData: Codable {
    let deviceId: String
    let profileId: Int
    let covidPass: String
    let status: String
    let nonce: String

    init(deviceId: String = Defaults.deviceId, profileId: Int? = Defaults.profileId, covidPass: String? = Defaults.covidPass, status: String, nonce: String) {
        self.deviceId = deviceId
        self.profileId = profileId ?? 0
        self.covidPass = covidPass ?? ""
        self.status = status
        self.nonce = nonce
    }
}

// MARK: - NCZI Services -
struct OTPSendRequestData: Codable {
    let vPhoneNumber: String
}

struct OTPValidateRequestData: Codable {
    let vPhoneNumber: String
    let nOTP: String
}
