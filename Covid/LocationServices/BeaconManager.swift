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

import CoreLocation
import CoreBluetooth

struct BeaconId {
    let minor: UInt16
    let major: UInt16
    let id: UInt32
    
    init(id: UInt32) {
        major = UInt16((id >> 16) & 0xFFFF)
        minor = UInt16(id & 0xFFFF)
        self.id = id
    }
    
    init(major: UInt16, minor: UInt16) {
        var value: UInt32 = 0
        value = value | UInt32(major)
        value = value << 16
        value = value | UInt32(minor)
        id = value
        self.major = major
        self.minor = minor
    }
}

class BeaconManager: NSObject {
    static var shared = BeaconManager()
    
    private var monitoringRegion: CLBeaconRegion?
    private var myRegion: CLBeaconRegion?
    private let locationManager = CLLocationManager()
    private let regionUUID = UUID(uuidString: "fb4f89f2-4b6c-48c5-9cc1-e70a6ef5cfdb")!
    
    private var peripheralManager: CBPeripheralManager!
    private var advertisingBeacon: BeaconId?
    private var lastLocation: CLLocation?
    
    private override init() {
        super.init()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self

        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: [
                CBPeripheralManagerOptionShowPowerAlertKey: true,
//                CBPeripheralManagerOptionRestoreIdentifierKey: "advertiserIdentifier"
            ]
        )
    }

    func startMonitoring() {
        setupMonitoringRegion()
        if let monitoringRegion = monitoringRegion {
            locationManager.startMonitoring(for: monitoringRegion)
            print("start monitor")
        }
    }
    
    func advertiseDevice(beacon: BeaconId) {
        setupAdvertisingRegion(beacon: beacon)
        guard let myRegion = myRegion else { return }
         
        if !peripheralManager.isAdvertising {
            advertisingBeacon = beacon
            if peripheralManager.state == .poweredOn, let peripheralData = myRegion.peripheralData(withMeasuredPower: nil) as? [String: Any] {
                peripheralManager.startAdvertising(peripheralData)
            }
        }
    }
}

extension BeaconManager {
    private func setupMonitoringRegion() {
        if #available(iOS 13.0, *) {
            monitoringRegion = CLBeaconRegion(uuid: regionUUID, identifier: "monitoring")
        } else {
            monitoringRegion = CLBeaconRegion(proximityUUID: regionUUID, identifier: "monitoring")
        }
    }
    
    private func setupAdvertisingRegion(beacon: BeaconId) {
        let beaconID = "beacon-\(beacon.major)-\(beacon.minor)"
        if #available(iOS 13.0, *) {
            myRegion = CLBeaconRegion(uuid: regionUUID, major: beacon.major, minor: beacon.minor, identifier: beaconID)
        } else {
            myRegion = CLBeaconRegion(proximityUUID: regionUUID, major: beacon.major, minor: beacon.minor, identifier: beaconID)
        }
    }
}

extension BeaconManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("STATE: \(peripheral.state.rawValue)")
        if peripheral.state == .poweredOn, let beacon = advertisingBeacon {
            advertiseDevice(beacon: beacon)
        }
    }

//    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
//        print("STATE REST: \(dict)")
//    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Advertising ERROR: \(error.localizedDescription)")
        } else {
            print("start advert")
        }
    }
}

extension BeaconManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("exit")
        if let reg = monitoringRegion {
            locationManager.stopRangingBeacons(in: reg)
            locationManager.stopUpdatingLocation()
            lastLocation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("enter")
        if let reg = monitoringRegion {
            locationManager.startUpdatingLocation()
            locationManager.startRangingBeacons(in: reg)
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        LocationReporter.shared.didRangeBeacons(beacons, at: lastLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
      print("Failed monitoring region: \(error.localizedDescription)")
    }
      
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location manager failed: \(error.localizedDescription)")
    }
}
