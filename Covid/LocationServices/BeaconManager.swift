import CoreLocation
import CoreBluetooth

class BeaconManager: NSObject {
    static var shared = BeaconManager()
    
    private var monitoringRegion: CLBeaconRegion?
    private var myRegion: CLBeaconRegion?
    private let locationManager = CLLocationManager()
    private let regionUUID = UUID(uuidString: "fb4f89f2-4b6c-48c5-9cc1-e70a6ef5cfdb")!
    private let major : CLBeaconMajorValue = UInt16.random(in: 0 ... 65535)
    private let minor : CLBeaconMinorValue = UInt16.random(in: 0 ... 65535)
    private let beaconID = "device-\(["a", "b", "c", "d", "e", "f"].randomElement()!)"
    private var count = 0
    
    private var peripheralManager: CBPeripheralManager?
    
    private override init() {
        super.init()
//        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
//        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        createBeaconRegions()
//        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        if let monitoringRegion = monitoringRegion {
            locationManager.startMonitoring(for: monitoringRegion)
//            locationManager.startUpdatingLocation()
        }
    }
    
    func advertiseDevice() {
        guard let myRegion = myRegion else { return }
        if !peripheralManager!.isAdvertising && peripheralManager!.state == .poweredOn {
            let peripheralData = myRegion.peripheralData(withMeasuredPower: nil)
            peripheralManager?.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
        }
    }
}

extension BeaconManager {
    private func createBeaconRegions() {
        if #available(iOS 13.0, *) {
            monitoringRegion = CLBeaconRegion(uuid: regionUUID, identifier: beaconID)
            myRegion = CLBeaconRegion(uuid: regionUUID, major: major, minor: minor, identifier: beaconID)
        } else {
            monitoringRegion = CLBeaconRegion(proximityUUID: regionUUID, identifier: beaconID)
            myRegion = CLBeaconRegion(proximityUUID: regionUUID, major: major, minor: minor, identifier: beaconID)
        }
    }
}

extension BeaconManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print(peripheral.state.rawValue)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Advertising ERROR: \(error.localizedDescription)")
        }
    }
}

extension BeaconManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        advertiseDevice()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("exit \(region)")
        if let reg = monitoringRegion {
            locationManager.stopRangingBeacons(in: reg)
            locationManager.stopMonitoring(for: reg)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(region)
        if let reg = monitoringRegion {
            locationManager.startMonitoring(for: reg)
            locationManager.startRangingBeacons(in: reg)
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("beacons \(beacons)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
      print("Failed monitoring region: \(error.localizedDescription)")
    }
      
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location manager failed: \(error.localizedDescription)")
    }
}
