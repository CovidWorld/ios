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
//  FaceID.swift
//  Covid
//
//  Created by Boris Bielik on 04/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import DOT
import AVKit

struct FaceID {

    static var faceIDMatchThreshold: Int {
        guard let treshold = Firebase.remoteConfig?.configValue(forKey: "faceIDMatchThreshold").numberValue else {
            return 85
        }
        return treshold.intValue
    }

    static var faceDetectionConfidenceThreshold: Int {
        guard let treshold = Firebase.remoteConfig?.configValue(forKey: "faceIDConfidenceThreshold").numberValue else {
            return 600
        }
        return treshold.intValue
    }

    static func initialize() {
        if let path = Bundle.main.path(forResource: "iengine", ofType: "lic") {
            do {
                let license = try License(path: path)

                DOTHandler.initialize(with: license,
                                      faceDetectionConfidenceThreshold: faceDetectionConfidenceThreshold)
                DOTHandler.localizationBundle = .main
            } catch {
                print(error)
            }
        }
    }

    static func deinitialize() {
        DOTHandler.deinitialize()
    }

    func checkCameraPermission(status: AVAuthorizationStatus,
                               controller: UIViewController,
                               onAuthorized: @escaping () -> Void,
                               onCancel: @escaping () -> Void) {
        if status != .authorized {
            let alertController = UIAlertController(title: "Nie je povolená kamera",
                                                    message: "Vstúpiť do Nastavení?",
                                                    preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Nastavenia", style: .default) { (_) -> Void in
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(settingsUrl)
            }

            let cancelAction = UIAlertAction(title: "Zrušiť", style: .cancel) { _ -> Void in
                onCancel()
            }

            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            alertController.preferredAction = settingsAction

            controller.present(alertController, animated: true, completion: nil)
        } else {
            onAuthorized()
        }
    }
}
