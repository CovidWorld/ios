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
//  LocationReporter.swift
//  Covid
//
//  Created by Boris Kolozsi on 17/03/2020.
//

import CoreLocation
import UIKit
import SwiftyUserDefaults

final class LocationReporter {
    static let shared = LocationReporter()

    private let networkService = CovidService()

    private init() { }

    @discardableResult
    func reportExit(distance: CLLocationDistance) -> Bool {
        guard Defaults.quarantineActive, Firebase.remoteDoubleValue(for: .desiredPositionAccuracy) < distance else { return false }

        let quarantineLocationPeriodMinutes = Firebase.remoteDoubleValue(for: .quarantineLocationPeriodMinutes)
        let currentTimestamp = Date().timeIntervalSince1970
        let lastTimestamp = Defaults.lastQuarantineUpdate ?? 0

        guard currentTimestamp - lastTimestamp > Double(quarantineLocationPeriodMinutes * 60) else { return false }

        let message = Firebase.remoteStringValue(for: .quarantineLeftMessage)

        Defaults.lastQuarantineUpdate = currentTimestamp

        if UIApplication.shared.applicationState == .active {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Zavrieť", style: .cancel)
            alertController.addAction(cancelAction)

            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        } else {
            let content = UNMutableNotificationContent()
            content.title = "Upozornenie"
            content.body = message
            content.sound = .default
            content.categoryIdentifier = "Quarantine"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "Quarantine", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }

        sendAreaExit(distance)
        return true
    }

    private func sendAreaExit(_ distance: CLLocationDistance) {
        guard Firebase.remoteBoolValue(for: .reportQuarantineExit) else { return }

        let data = AreaExitRequestData(severity: Int(distance))
        networkService.requestAreaExit(areaExitRequestData: data) { _ in }
    }
}
