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
import SwiftyUserDefaults
import FirebaseCore
import FirebaseCrashlytics
import FirebaseAnalytics
import FirebaseRemoteConfig
import FirebaseMessaging

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
        Messaging.messaging().delegate = self

        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 150 / 255.0, green: 161 / 255.0, blue: 205 / 255.0, alpha: 1)

        // TODO: mock
        Defaults.covidPass = "abc-21s-r47"

        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Defaults.quarantineActive {
            LocationTracker.shared.startLocationTracking()

            completionHandler(.newData)
            return
        }
        completionHandler(.noData)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
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

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Defaults.FCMToken = fcmToken
    }
}

extension AppDelegate {
    private func setupFirebaseConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
        guard let remoteConfig = remoteConfig else { return }

        let defaults: [String: NSObject] = RemoteConfigKey.allCases.reduce([String: NSObject]()) { (result, value) in
            var result = result
            result[value.rawValue] = value.defaultValue
            return result
        }

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
