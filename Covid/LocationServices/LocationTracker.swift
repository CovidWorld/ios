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
//  LocationTracker.swift
//  Covid
//
//  Created by Boris Kolozsi on 14/03/2020.
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
            let alertController = UIAlertController(title: "Nastavenia", message: "Máte zakázané využívanie lokalizačných služieb. Pre správne fungovanie si zmeňte nastavenia", preferredStyle: .alert)
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
