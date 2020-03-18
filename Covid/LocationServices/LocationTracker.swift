//
//  LocationTracker.swift
//  Covid
//
//  Created by Boris Kolozsi on 14/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationTracker: NSObject {

    var timeInternal = TimeInterval(60)
    var accuracy = CLLocationAccuracy(250)
    static let shared = LocationTracker()
    
    private let manager = LocationManagerHandler()
    private var statusCheckedOnce = false
    private let networkService = CovidService()
    
    var isLocationServiceEnabled: Bool {
        return CLLocationManager.authorizationStatus() != .denied
    }

    override init() {
        super.init()
        
        manager.delegate = self
        
        if let accuracy = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?.configValue(forKey: "desiredPositionAccuracy").numberValue?.intValue {
            self.accuracy = CLLocationAccuracy(accuracy)
        }
    }
    
    func startLocationTracking() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            manager.startUpdatingLocation(interval: timeInternal, acceptableLocationAccuracy: accuracy)
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation(interval: timeInternal, acceptableLocationAccuracy: accuracy)
        } else if CLLocationManager.authorizationStatus() == .denied{
            let alertController = UIAlertController(title: "Nastavenia", message: "Máte zakázané využívanie lokalizačných služieb. Pre správne fungovanie si upravte nastavenia", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Zavrieť", style: .cancel)
            let settingsAction = UIAlertAction(title: "Nastavenia", style: .default) { (_) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }else{
            manager.requestAlwaysAuthorization()
        }
    }
    
    func stopLocationTracking() {
        manager.stopUpdatingLocation()
    }
}

extension LocationTracker: LocationManagerHandlerDelegate{
    
    func scheduledLocationManager(_ manager: LocationManagerHandler, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            LocationReporter.shared.reportLocation(location)
        }
    }
    
    func scheduledLocationManager(_ manager: LocationManagerHandler, didFailWithError error: Error) {
        print(error)
    }
    
    func scheduledLocationManager(_ manager: LocationManagerHandler, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .denied{
            //TODO: alert
            print("disabled")
        }else{
            startLocationTracking()
        }
    }
}
