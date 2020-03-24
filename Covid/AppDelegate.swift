//
//  AppDelegate.swift
//  Covid
//
//  Created by Boris Kolozsi on 09/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit
import Firebase
import SwiftyUserDefaults
import FirebaseCrashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var remoteConfig: RemoteConfig?
    var backgroundTaskID: UIBackgroundTaskIdentifier?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setupFirebaseConfig()
        Crashlytics.crashlytics().setUserID(Defaults.deviceId)
        
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

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        let token = deviceToken.reduce("") { $0 + String(format: "%02.2hhx", $1) }
        Defaults.pushToken = token
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
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
            if rootVC?.isKind(of: UINavigationController.self) ?? false {
                let navigationController = rootVC as! UINavigationController
                return visibleViewController(navigationController.viewControllers.last!)
            }
            
            if rootVC?.isKind(of: UITabBarController.self) ?? false {
                let tabBarController = rootVC as! UITabBarController
                return visibleViewController(tabBarController.selectedViewController!)
            }
            
            return rootVC
        }

        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last
            }

            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
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
                                            "quarantineLeftMessage": NSString(string: "Opustili ste zónu domácej karatnény. Pre ochranu Vášho zdravia a zdravia Vašich blízkych, Vás žiadame o striktné dodržiavanie nariadenej karantény."),
                                            "batchSendingFrequency": NSNumber(value: 60),
                                            "quarantineLocationPeriodMinutes": NSNumber(value: 5),
                                            "minConnectionDuration": NSNumber(value: 300),
                                            "mapStatsUrl": NSString(string: "https://portal.minv.sk/gis/rest/services/PROD/ESISPZ_GIS_PORTAL_CovidPublic/MapServer/4/query?where=POTVRDENI%20%3E%200&f=json&outFields=IDN3%2C%20NM3%2C%20IDN2%2C%20NM2%2C%20POTVRDENI%2C%20VYLIECENI%2C%20MRTVI%2C%20AKTIVNI%2C%20CAKAJUCI%2C%20OTESTOVANI_NEGATIVNI%2C%20DATUM_PLATNOST&returnGeometry=false&orderByFields=POTVRDENI%20DESC"),
                                            "apiHost": NSString(string: "https://covid-gateway.azurewebsites.net"),
                                            "statsUrl": NSString(string: "https://corona-stats-sk.herokuapp.com/combined")]
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(defaults)
        remoteConfig.fetch { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig?.activate(completionHandler: { (error) in
              // ...
            })
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
        }
    }
}

