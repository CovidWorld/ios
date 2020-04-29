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
//  PermissionHandler.swift
//  Covid
//
//  Created by Boris Bielik on 23/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import CoreBluetooth
import CoreLocation

final class Permissions {
    static let shared = Permissions()
    private (set) var pendingRequests: [PermissionRequest] = []

    var requiredPermissions: [SPPermission] {
        [.notification,
         .locationAlwaysAndWhenInUse,
         .bluetooth]
    }

    @SwiftyUserDefault(keyPath: \.didAskForPermissions, options: [.cached, .observed])
    var didAskForPermissions: Bool?

    private init() {}

    func requestAuthorization(for permission: SPPermission, completion: (() -> Void
        )? = nil) {
        request(for: permission) {
            permission.request {
                completion?()
            }
        }
    }

    func request(for permission: SPPermission, block: @escaping () -> Void) {
        if didAskForPermissions == true {
            block()
        } else {
            let request = PermissionRequest(permission: permission, block: block)
            pendingRequests.append(request)
        }
    }
}

struct PermissionRequest {
    let permission: SPPermission
    let block: () -> Void
}

// MARK: Location

extension Permissions {

    static var isLocationEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    static var location: SPPermission {
        SPPermission.locationAlwaysAndWhenInUse
    }

    static var isLocationAuthorized: Bool {
        isLocationAuthorizedAlways || isLocationAuthorizedWhenInUse
    }

    static var isLocationAuthorizedAlways: Bool {
        SPPermission.locationAlwaysAndWhenInUse.isAuthorized
    }

    static var isLocationAuthorizedWhenInUse: Bool {
        SPPermission.locationAlwaysAndWhenInUse.isAuthorized
    }

    static func requestLocationAuthorization() {
        Permissions.shared.requestLocationAuthorization()
    }

    func requestLocationAuthorization() {
        requestAuthorization(for: .locationAlwaysAndWhenInUse)
    }
}

// MARK: Push notifications

extension Permissions {

    static var notifications: SPPermission {
        SPPermission.notification
    }

    static func requestNotifications() {
        shared.requestAuthorization(for: .notification)
    }
}

// MARK: Bluetooth

extension Permissions {

    static var isBluetoothEnabled: Bool {
        BeaconManager.shared.bluetoothIsOn
    }

    static var bluetooth: SPPermission {
        SPPermission.bluetooth
    }
}
