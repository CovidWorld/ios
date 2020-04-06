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
//  AppDelegate.swift
//  Covid
//
//  Created by Boris Kolozsi on 09/03/2020.
//

import UIKit
import Firebase
import SwiftyUserDefaults
import FirebaseCrashlytics
import FirebaseRemoteConfig

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var remoteConfig: RemoteConfig?
    var backgroundTaskID: UIBackgroundTaskIdentifier?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        guard !isRunningUnitTests else {
            window = nil
            return true
        }
        #endif

        FirebaseApp.configure()
        setupFirebaseConfig()
        Crashlytics.crashlytics().setUserID(Defaults.deviceId)
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 150 / 255.0, green: 161 / 255.0, blue: 205 / 255.0, alpha: 1)
        if !Defaults.didRunApp {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let exampleViewController = mainStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
            self.window?.rootViewController = exampleViewController
            self.window?.makeKeyAndVisible()
        }

        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        if let profileId = Defaults.profileId {
            BeaconManager.shared.advertiseDevice(beacon: BeaconId(id: UInt32(profileId)))
            BeaconManager.shared.startMonitoring()
        }
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let profileId = Defaults.profileId {
            LocationReporter.shared.sendConnections()
            BeaconManager.shared.advertiseDevice(beacon: BeaconId(id: UInt32(profileId)))
            BeaconManager.shared.startMonitoring()

            if Defaults.quarantineActive {
                LocationTracker.shared.startLocationTracking()
            }
            completionHandler(.newData)
            return
        }
        completionHandler(.noData)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02.2hhx", $1) }
        Defaults.pushToken = token
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .active {
            var message: String?
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let alertMessage = alert["body"] as? String {
                        message = alertMessage
                    }
                }
            }

            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Zavrieť", style: .cancel)
            alertController.addAction(cancelAction)

            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        completionHandler(.noData)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        setupFirebaseConfig()
    }

    func visibleViewController(_ rootViewController: UIViewController? = nil) -> UIViewController? {

        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }

        if rootVC?.presentedViewController == nil {
            if let navigationController = rootVC as? UINavigationController {
                return visibleViewController(navigationController.viewControllers.last)
            }

            if let tabBarController = rootVC as? UITabBarController {
                return visibleViewController(tabBarController.selectedViewController)
            }

            return rootVC
        }

        if let presented = rootVC?.presentedViewController {
            if let navigationController = presented as? UINavigationController {
                return navigationController.viewControllers.last
            }

            if let tabBarController = presented as? UITabBarController {
                return tabBarController.selectedViewController
            }

            return visibleViewController(presented)
        }
        return nil
    }
}

extension AppDelegate {
    private func setupFirebaseConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
        guard let remoteConfig = remoteConfig else { return }

        let defaults: [String: NSObject] = ["quarantineDuration": NSString(string: "14"),
                                            "desiredPositionAccuracy": NSNumber(value: 100),
                                            "quarantineLeftMessage": NSString(string: "Opustili ste zónu domácej karantény. Pre ochranu Vášho zdravia a zdravia Vašich blízkych, Vás žiadame o striktné dodržiavanie nariadenej karantény."),
                                            "batchSendingFrequency": NSNumber(value: 60),
                                            "quarantineLocationPeriodMinutes": NSNumber(value: 5),
                                            "minConnectionDuration": NSNumber(value: 300),
                                            "mapStatsUrl": NSString(string: "https://portal.minv.sk/gis/rest/services/PROD/ESISPZ_GIS_PORTAL_CovidPublic/MapServer/4/query?where=POTVRDENI%20%3E%200&f=json&outFields=IDN3%2C%20NM3%2C%20IDN2%2C%20NM2%2C%20POTVRDENI%2C%20VYLIECENI%2C%20MRTVI%2C%20AKTIVNI%2C%20CAKAJUCI%2C%20OTESTOVANI_NEGATIVNI%2C%20DATUM_PLATNOST&returnGeometry=false&orderByFields=POTVRDENI%20DESC"),
                                            "apiHost": NSString(string: "https://covid-gateway.azurewebsites.net"),
                                            "statsUrl": NSString(string: "https://corona-stats-sk.herokuapp.com/combined"),
                                            "faceIDConfidenceThreshold": NSNumber(value: 600),
                                            "faceIDMatchThreshold": NSNumber(value: 75)]

        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(defaults)
        remoteConfig.fetch { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig?.activate { _ in }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
        }
    }
}

struct Firebase {

    static var remoteConfig: RemoteConfig? {
        (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig
    }
}

// MARK: Test target

#if DEBUG
extension AppDelegate {

    private var isRunningUnitTests: Bool {
        let env = ProcessInfo.processInfo.environment
        print("ENV KEYS: \(env.keys)")
        return env.keys.contains("XCInjectBundleInto")
    }
}
#endif
