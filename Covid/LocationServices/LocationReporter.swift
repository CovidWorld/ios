//
//  LocationReporter.swift
//  Covid
//
//  Created by Boris Kolozsi on 17/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import CoreLocation
import UIKit
import SwiftyUserDefaults

class LocationReporter {
    static let shared = LocationReporter()
    
    private let networkService = CovidService()
    
    private init() { }
    
    func reportLocation(_ location: CLLocation) {
        guard let quarantineLatitude = Defaults.quarantineLatitude, let quarantineLongitude = Defaults.quarantineLongitude, Defaults.quarantineActive else { return }
        
        let quarantineLocation = CLLocation(latitude: quarantineLatitude, longitude: quarantineLongitude)
        //TODO: nicer
        let distance = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?["desiredPositionAccuracy"].numberValue?.doubleValue ?? 100.0
        let treshold = max(location.horizontalAccuracy * 2, distance)
        let message = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?["quarantineLeftMessage"].stringValue ?? "Opustili ste zónu domácej karatnény. Pre ochranu Vášho zdravia a zdravia Vašich blízkych, Vás žiadame o striktné dodržiavanie nariadenej karantény."
        
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
        networkService.requestAreaExit(areaExitRequestData: AreaExitRequestData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, accuracy: Int(location.horizontalAccuracy))) { (result) in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
    
    private func sendLocationUpdate(_ location: CLLocation) {
        let location = Location(recordTimestamp: Int(Date().timeIntervalSince1970), latitude: location.coordinate.latitude, longitude: location.coordinate.latitude, accuracy: location.horizontalAccuracy)
        try? Disk.append(location, to: "locations.json", in: .applicationSupport)
        
        let batchTime = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?["batchSendingFrequency"].numberValue?.intValue ?? 60
        
        let currentTimestamp = Date().timeIntervalSince1970
        let lastTimestamp = Defaults.lastLocationUpdate ?? Date().timeIntervalSince1970
        
        if Defaults.lastLocationUpdate == nil || currentTimestamp - lastTimestamp > Double(batchTime * 60) {
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
