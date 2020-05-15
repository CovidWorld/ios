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
//  LocationMonitoring.swift
//  Covid
//
//  Created by Boris Kolozsi on 15/05/2020.
//

import UIKit
import CoreLocation
import SwiftyUserDefaults

final class LocationMonitoring: NSObject {
    static let shared = LocationMonitoring()
    static let quarantineRegionIdentifier = "region.quarantine"

    let manager = CLLocationManager()

    override init() {
        super.init()

        manager.delegate = self
    }

    class func monitorLocationIfNeeded() {
        // TODO: apply rules
        LocationMonitoring.shared.setQurantineRegion(center: CLLocationCoordinate2D(latitude: 48.145842, longitude: 17.126651), radius: Firebase.remoteDoubleValue(for: .desiredPositionAccuracy))
    }

    private func setQurantineRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        if let region = manager.monitoredRegions.first(where: {$0.identifier == LocationMonitoring.quarantineRegionIdentifier}) {
            manager.stopMonitoring(for: region)
        }

        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let accuracy = min(manager.maximumRegionMonitoringDistance, Firebase.remoteDoubleValue(for: .desiredPositionAccuracy))
            let region = CLCircularRegion(center: center,
                                          radius: accuracy,
                                          identifier: LocationMonitoring.quarantineRegionIdentifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true

            manager.startMonitoring(for: region)
        }
        // TODO: error
    }
}

extension LocationMonitoring: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let distance = manager.location?.distance(from: region.center.location)
            LocationReporter.shared.reportExit(distance: distance ?? 0)
        }
    }
}
