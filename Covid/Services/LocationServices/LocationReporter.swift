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

    func didRangeBeacons(_ beacons: [CLBeacon], at location: CLLocation?) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let accuracy = Firebase.remoteConfig?.configValue(forKey: "ibeaconLocationAccuracy").numberValue ?? -1
        var approxLatitude: Double?
        var approxLongitude: Double?
        var accuracyFactor = 0.0
        let connections = beacons.compactMap { (beacon) -> Connection in
            let beaconId = BeaconId(major: beacon.major.uint16Value, minor: beacon.minor.uint16Value)
            if accuracy != -1 {
                accuracyFactor = Double(truncating: pow(10, accuracy.intValue) as NSNumber)
                approxLatitude = Double(round(accuracyFactor * (location?.coordinate.latitude ?? 0)) / accuracyFactor)
                approxLongitude = Double(round(accuracyFactor * (location?.coordinate.longitude ?? 0)) / accuracyFactor)
            }

            return Connection(seenProfileId: Int(beaconId.id),
                              timestamp: timestamp,
                              duration: "",
                              latitude: approxLatitude,
                              longitude: approxLongitude,
                              accuracy: accuracyFactor)
        }
        try? Disk.append(connections, to: "connections.json", in: .applicationSupport)
        sendConnections()
    }

    func sendConnections() {
        let batchTime = Firebase.remoteConfig?["batchSendingFrequency"].numberValue?.intValue ?? 60
        let currentTimestamp = Date().timeIntervalSince1970
        let lastTimestamp = Defaults.lastConnectionsUpdate ?? Date().timeIntervalSince1970

        if Defaults.lastConnectionsUpdate == nil || currentTimestamp - lastTimestamp > Double(batchTime * 60) {
            guard
                var connections = try? Disk.retrieve("connections.json",
                                                     from: .applicationSupport,
                                                     as: [Connection].self),
                connections.count > 0
                else { return }

            connections = connections.sorted { abs($0.latitude ?? 0) > abs($1.latitude ?? 0) }
            connections = Array(Set(connections))

            networkService.uploadConnections(uploadConnectionsRequestData: UploadConnectionsRequestData(connections: connections)) { (result) in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        Defaults.lastConnectionsUpdate = currentTimestamp
                        try? Disk.remove("connections.json", from: .applicationSupport)
                    }
                case .failure: print("batch failed")
                }
            }
        }
    }

    func reportLocation(_ location: CLLocation) {
        guard
            let quarantineLatitude = Defaults.quarantineLatitude,
            let quarantineLongitude = Defaults.quarantineLongitude,
            Defaults.quarantineActive
            else { return }

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let quarantineLocationPeriodMinutes = appDelegate?.remoteConfig?["quarantineLocationPeriodMinutes"].numberValue?.intValue ?? 5
        let currentTimestamp = Date().timeIntervalSince1970
        let lastTimestamp = Defaults.lastQuarantineUpdate ?? 0

        guard currentTimestamp - lastTimestamp > Double(quarantineLocationPeriodMinutes * 60) else { return }

        let quarantineLocation = CLLocation(latitude: quarantineLatitude, longitude: quarantineLongitude)
        // TODO: nicer
        let distance = appDelegate?.remoteConfig?["desiredPositionAccuracy"].numberValue?.doubleValue ?? 100.0
        let treshold = max(location.horizontalAccuracy * 2, distance)
        let defaultMessage = "Opustili ste zónu domácej karantény. Pre ochranu Vášho zdravia a zdravia Vašich blízkych, Vás žiadame o striktné dodržiavanie nariadenej karantény."
        let message = appDelegate?.remoteConfig?["quarantineLeftMessage"].stringValue ?? defaultMessage

        Defaults.lastQuarantineUpdate = currentTimestamp

        if quarantineLocation.distance(from: location) > treshold {
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

            sendAreaExitAtLocation(location)
        } else {
            sendLocationUpdate(location)
        }
    }

    private func sendAreaExitAtLocation(_ location: CLLocation) {
        let data = AreaExitRequestData(latitude: location.coordinate.latitude,
                                       longitude: location.coordinate.longitude,
                                       accuracy: Int(location.horizontalAccuracy))
        networkService.requestAreaExit(areaExitRequestData: data) { _ in }
    }

    private func sendLocationUpdate(_ location: CLLocation) {
        let location = Location(recordTimestamp: Int(Date().timeIntervalSince1970),
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude,
                                accuracy: location.horizontalAccuracy)
        try? Disk.append(location, to: "locations.json", in: .applicationSupport)

        let batchTime = Firebase.remoteConfig?["batchSendingFrequency"].numberValue?.intValue ?? 60

        let currentTimestamp = Date().timeIntervalSince1970
        let lastTimestamp = Defaults.lastLocationUpdate ?? 0

        if currentTimestamp - lastTimestamp > Double(batchTime * 60) {
            guard let locations = try? Disk.retrieve("locations.json", from: .applicationSupport, as: [Location].self) else { return }

            networkService.requestLocations(locationsRequestData: LocationsRequestData(locations: locations)) { (result) in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        Defaults.lastLocationUpdate = currentTimestamp
                        try? Disk.remove("locations.json", from: .applicationSupport)
                    }
                case .failure: print("batch failed")
                }
            }
        }
    }
}
