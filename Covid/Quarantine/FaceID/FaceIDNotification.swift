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
//  FaceIDNotification.swift
//  Covid
//
//  Created by Boris Bielik on 04/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let startFaceIDRegistration = Notification.Name("com.covid.startFaceIDRegistration")
}

struct StartFaceIDRegistrationNotification {
    static let navigationControllerKey = "navigationControllerKey"
    static let completionKey = "completionKey"

    static func notification(with navigationController: UINavigationController, completion: @escaping () -> Void) -> Notification {
        let userInfo = [navigationControllerKey: navigationController, completionKey: completion] as [String: Any]
        return Notification(name: .startFaceIDRegistration,
                     object: nil,
                     userInfo: userInfo)
    }

    static func navigationController(from notification: Notification) -> UINavigationController? {
        guard
            notification.name == .startFaceIDRegistration,
            let navigationController = notification.userInfo?[navigationControllerKey] as? UINavigationController else { return nil }

        return navigationController
    }

    static func completion(from notification: Notification) -> (() -> Void)? {
        guard
            notification.name == .startFaceIDRegistration,
            let completion = notification.userInfo?[completionKey] as? () -> Void else { return nil }

        return completion
    }
}
