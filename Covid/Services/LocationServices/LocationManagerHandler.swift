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
//  LocationManagerHandler.swift
//  Covid
//
//  Created by Boris Kolozsi on 14/03/2020.
//

import Foundation
import CoreLocation
import UIKit

public protocol LocationManagerHandlerDelegate: class {

    func scheduledLocationManager(_ manager: LocationManagerHandler, didFailWithError error: Error)
    func scheduledLocationManager(_ manager: LocationManagerHandler, didUpdateLocations locations: [CLLocation])
    func scheduledLocationManager(_ manager: LocationManagerHandler, didChangeAuthorization status: CLAuthorizationStatus)
}

public class LocationManagerHandler: NSObject {

    weak var delegate: LocationManagerHandlerDelegate?

    private let MaxBGTime: TimeInterval = 170
    private let MinBGTime: TimeInterval = 2
    private let MinAcceptableLocationAccuracy: CLLocationAccuracy = 5
    private let WaitForLocationsTime: TimeInterval = 3

    private let manager = CLLocationManager()

    private var isManagerRunning = false
    private var checkLocationTimer: Timer?
    private var waitTimer: Timer?
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var lastLocations = [CLLocation]()

    public private(set) var acceptableLocationAccuracy: CLLocationAccuracy = 100
    public private(set) var checkLocationInterval: TimeInterval = 10
    public private(set) var isRunning = false

    override public init() {
        super.init()

        configureLocationManager()
    }

    private func configureLocationManager() {
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
    }

    public func requestAlwaysAuthorization() {
        Permissions.requestLocationAuthorization()
    }

    public func startUpdatingLocation(interval: TimeInterval, acceptableLocationAccuracy: CLLocationAccuracy = 100) {

        if isRunning {
            stopUpdatingLocation()
        }

        checkLocationInterval -= WaitForLocationsTime
        checkLocationInterval = min(max(MinBGTime, interval), MaxBGTime)
        self.acceptableLocationAccuracy = max(acceptableLocationAccuracy, MinAcceptableLocationAccuracy)

        isRunning = true

        addNotifications()
        startLocationManager()
    }

    public func stopUpdatingLocation() {
        isRunning = false
        stopWaitTimer()
        stopLocationManager()
        stopBackgroundTask()
        stopCheckLocationTimer()
        removeNotifications()
    }

    @objc
    func applicationDidBecomeActive() {
        stopBackgroundTask()
    }

    private func startCheckLocationTimer() {

        stopCheckLocationTimer()

        checkLocationTimer = Timer.scheduledTimer(withTimeInterval: checkLocationInterval,
                                                  repeats: false) { [weak self] _ in
            self?.checkLocationTimerEvent()
        }
    }

    private func stopCheckLocationTimer() {
        if let timer = checkLocationTimer {
            timer.invalidate()
            checkLocationTimer = nil
        }
    }

    @objc
    func checkLocationTimerEvent() {
        stopCheckLocationTimer()
        startLocationManager()

        self.perform(#selector(stopAndResetBgTaskIfNeeded), with: nil, afterDelay: 1)
    }

    @objc
    func waitTimerEvent() {

        stopWaitTimer()

        if acceptableLocationAccuracyRetrieved() {
            startBackgroundTask()
            startCheckLocationTimer()
            pauseLocationManager()
            delegate?.scheduledLocationManager(self, didUpdateLocations: lastLocations)
        } else {
            startWaitTimer()
        }
    }

    @objc
    func stopAndResetBgTaskIfNeeded() {
        if isManagerRunning {
            stopBackgroundTask()
        } else {
            stopBackgroundTask()
            startBackgroundTask()
        }
    }

    private func startBackgroundTask() {
        let state = UIApplication.shared.applicationState

        if (state == .background || state == .inactive) && bgTask == UIBackgroundTaskIdentifier.invalid {
            bgTask = UIApplication.shared.beginBackgroundTask {
                self.checkLocationTimerEvent()
            }
        }
    }

    private func stopBackgroundTask() {
        guard bgTask != UIBackgroundTaskIdentifier.invalid else { return }
        UIApplication.shared.endBackgroundTask(bgTask)
        bgTask = UIBackgroundTaskIdentifier.invalid
    }
}

extension LocationManagerHandler: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.scheduledLocationManager(self, didChangeAuthorization: status)
    }

   public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.scheduledLocationManager(self, didFailWithError: error)
   }

   public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

       guard isManagerRunning else { return }
       guard locations.count > 0 else { return }

       lastLocations = locations

       if waitTimer == nil {
           startWaitTimer()
       }
   }
}

// MARK: - Private -
extension LocationManagerHandler {
    private func addNotifications() {
        removeNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    private func startLocationManager() {
        isManagerRunning = true
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 10
        manager.startUpdatingLocation()
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                return
        }
        manager.startMonitoringSignificantLocationChanges()
    }

    private func pauseLocationManager() {
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.distanceFilter = 99999
    }
    private func stopLocationManager() {
        isManagerRunning = false
        manager.stopUpdatingLocation()
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                return
        }
        manager.stopMonitoringSignificantLocationChanges()
    }

    @objc
    func applicationDidEnterBackground() {
       stopBackgroundTask()
       startBackgroundTask()
    }

    private func startWaitTimer() {
        stopWaitTimer()
        waitTimer = Timer.scheduledTimer(timeInterval: WaitForLocationsTime, target: self, selector: #selector(waitTimerEvent), userInfo: nil, repeats: false)
    }

    private func stopWaitTimer() {
        if let timer = waitTimer {
            timer.invalidate()
            waitTimer = nil
        }
    }

    private func acceptableLocationAccuracyRetrieved() -> Bool {
        let location = lastLocations.last!
        return location.horizontalAccuracy <= acceptableLocationAccuracy ? true : false
    }
}
