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
//  Alert.swift
//  Covid
//
//  Created by Boris Kolozsi on 19/05/2020.
//

import UIKit

final class Alert {
    class func show(title: String?,
                    message: String?,
                    cancelTitle: String = "Zavrieť",
                    defaultTitle: String? = nil,
                    cancelAction: ((UIAlertAction) -> Void)? = nil,
                    defaultAction: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let action = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction)
            alert.addAction(action)

            if let defaultTitle = defaultTitle {
                let action = UIAlertAction(title: defaultTitle, style: .default, handler: defaultAction)
                alert.addAction(action)
                alert.preferredAction = action
            }

            if #available(iOS 13.0, *) {
                 if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.present(alert, animated: true, completion: nil)
                 }
            } else {
                let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                alertWindow.rootViewController = UIViewController()
                alertWindow.windowLevel = .alert + 1
                alertWindow.makeKeyAndVisible()
                alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}
