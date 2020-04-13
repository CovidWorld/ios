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
//  RemoteConfig.swift
//  Covid
//
//  Created by Boris Kolozsi on 09/04/2020.
//

import Foundation
import FirebaseRemoteConfig

enum RemoteConfigKey: String, CaseIterable {
    case quarantineDuration
    case desiredPositionAccuracy
    case quarantineLeftMessage
    case batchSendingFrequency
    case quarantineLocationPeriodMinutes
    case minConnectionDuration
    case mapStatsUrl
    case apiHost
    case ncziApiHost
    case statsUrl
    case faceIDConfidenceThreshold
    case faceIDMatchThreshold
    case iBeaconLocationAccuracy
    case hotlines

    var defaultValue: NSObject {
        switch self {
        case .quarantineDuration: return NSNumber(value: 14)
        case .desiredPositionAccuracy: return NSNumber(value: 100)
        case .quarantineLeftMessage: return NSString(string: """
            Opustili ste zónu domácej karantény. Pre ochranu Vášho zdravia a zdravia Vašich blízkych, \
            Vás žiadame o striktné dodržiavanie nariadenej karantény.
            """)
        case .batchSendingFrequency: return NSNumber(value: 60)
        case .quarantineLocationPeriodMinutes: return NSNumber(value: 5)
        case .minConnectionDuration: return NSNumber(value: 300)
        case .mapStatsUrl:
            return NSString(string: "https://portal.minv.sk/gis/rest/services/PROD/ESISPZ_GIS_PORTAL_CovidPublic/MapServer/4/query?where=POTVRDENI%20%3E%200&f=json&outFields=IDN3%2C%20NM3%2C%20IDN2%2C%20NM2%2C%20POTVRDENI%2C%20VYLIECENI%2C%20MRTVI%2C%20AKTIVNI%2C%20CAKAJUCI%2C%20OTESTOVANI_NEGATIVNI%2C%20DATUM_PLATNOST&returnGeometry=false&orderByFields=POTVRDENI%20DESC")
        case .apiHost: return NSString(string: "https://covid-gateway.azurewebsites.net")
        case .ncziApiHost: return NSString(string: "https://t.mojeezdravie.sk")
        case .statsUrl: return NSString(string: "https://corona-stats-sk.herokuapp.com/combined")
        case .faceIDConfidenceThreshold: return NSNumber(value: 600)
        case .faceIDMatchThreshold: return NSNumber(value: 75)
        case .iBeaconLocationAccuracy: return NSNumber(value: -1)
        case .hotlines: return NSDictionary(dictionary: ["SK": "0800221234"])
        }
    }
}

struct Firebase {

    static var remoteConfig: RemoteConfig? {
        (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig
    }

    static func remoteValue(for key: RemoteConfigKey) -> NSObject {
        remoteConfig?.configValue(forKey: key.rawValue) ?? key.defaultValue
    }

    static func remoteStringValue(for key: RemoteConfigKey) -> String {
        if let value = remoteConfig?.configValue(forKey: key.rawValue).stringValue {
            return value
        } else if let value = key.defaultValue as? String {
            return value
        } else {
            assertionFailure("default value should be available")
            return ""
        }
    }

    static func remoteDoubleValue(for key: RemoteConfigKey) -> Double {
        if let value = remoteConfig?.configValue(forKey: key.rawValue).numberValue {
            return value.doubleValue
        } else if let value = key.defaultValue as? NSNumber {
            return value.doubleValue
        } else {
            assertionFailure("default value should be available")
            return 0.0
        }
    }

    static func remoteDictionaryValue(for key: RemoteConfigKey) -> [String: AnyHashable] {
        if let value = remoteConfig?.configValue(forKey: key.rawValue).jsonValue as? [String: AnyHashable] {
            return value
        } else if let value = key.defaultValue as? [String: AnyHashable] {
            return value
        }
        return [String: AnyHashable]()
    }
}
