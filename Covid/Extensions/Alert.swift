//
//  Alert.swift
//  Covid
//
//  Created by Boris Kolozsi on 19/05/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit

final class Alert {
    class func show(title: String?,
                    message: String?,
                    cancelTitle: String? = nil,
                    defaultTitle: String? = nil,
                    cancelAction: ((UIAlertAction) -> Void)? = nil,
                    defaultAction: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let cancelTitle = cancelTitle {
            let action = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction)
            alert.addAction(action)
        }

        if let defaultTitle = defaultTitle {
            let action = UIAlertAction(title: defaultTitle, style: .default, handler: defaultAction)
            alert.addAction(action)
            alert.preferredAction = action
        }

        // show alert
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
