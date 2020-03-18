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
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Defaults.quarantineActive {
            LocationTracker.shared.startLocationTracking()
            completionHandler(.newData)
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if Defaults.needsFetchRemoteConfig {
            setupFirebaseConfig()
        }
    }
}

extension AppDelegate {
    private func setupFirebaseConfig() {
        Defaults.needsFetchRemoteConfig = false
        remoteConfig = RemoteConfig.remoteConfig()
        guard let remoteConfig = remoteConfig else { return }
        
        let defaults: [String: NSObject] = ["quarantineDuration": NSString(string: "14"),
                                            "desiredPositionAccuracy": NSString(string: "100"),
                                            "quarantineLeftMessage": NSString(string: "Opustili ste zónu domácej karatnény. Pre ochranu Vášho zdravia a zdravia Vašich blízkych, Vás žiadame o striktné dodržiavanie nariadenej karantény."),
                                            "batchSendingFrequency": NSNumber(value: 60)]
        
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

