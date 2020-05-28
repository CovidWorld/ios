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

import UIKit
import AVFoundation
import CoreLocation

enum AccessPermission {
    case ok
    case error

    var text: String {
        switch self {
        case .ok:
            return LocalizedString(forKey: "button.ok")
        case .error:
            return LocalizedString(forKey: "button.error")
        }
    }
    var color: UIColor {
        switch self {
        case .ok:
            return .green
        case .error:
            return .red
        }
    }
}

final class SelectAddressInfoViewController: ViewController {

    @IBOutlet private weak var cameraAccessLabel: UILabel!
    @IBOutlet private weak var locationAccessLabel: UILabel!

    var onContinue: (() -> Void)?

    private let locationManager = CLLocationManager()
    private var permissions: (camera: AccessPermission, location: AccessPermission) = (.error, .error)

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkAccess()
    }

    @objc
    private func applicationDidBecomeActive() {
        checkAccess()
    }

    @IBAction private func didTapContinue(_ sender: Any) {
        if permissions.camera == .error {
            presentSettings(message: LocalizedString(forKey: "permission.camera.denied"))
        } else if permissions.location == .error {
            presentSettings(message: LocalizedString(forKey: "permission.location.denied"))
        } else {
            onContinue?()
        }
    }

    private func checkAccess() {
        checkCameraAccess { [weak self] result in

            DispatchQueue.main.async {
                self?.permissions.camera = result
                self?.cameraAccessLabel.text = result.text
                self?.cameraAccessLabel.textColor = result.color
                self?.checkLocationAccess { result in
                    self?.permissions.location = result
                    self?.locationAccessLabel.text = result.text
                    self?.locationAccessLabel.textColor = result.color
                }
            }
        }
    }

    private func checkCameraAccess(completion: @escaping (AccessPermission) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            completion(.error)
        case .authorized:
            completion(.ok)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                DispatchQueue.main.async {
                    if success {
                        completion(.ok)
                    } else {
                        completion(.error)
                    }
                }
            }
        @unknown default:
            break
        }
    }

    private func checkLocationAccess(completion: (AccessPermission) -> Void) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            // netreba completion, zavola sa didBecomeActive
            case .restricted, .denied:
                completion(.error)
            case .authorizedAlways, .authorizedWhenInUse:
                completion(.ok)
            @unknown default:
                break
            }
        } else {
            completion(.error)
        }
    }

    private func presentSettings(message: String) {
        let alertController = UIAlertController(title: LocalizedString(forKey: "error.title"),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: LocalizedString(forKey: "button.cancel"), style: .cancel))
        let defaultAction = UIAlertAction(title: LocalizedString(forKey: "permission.settings"), style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        alertController.addAction(defaultAction)
        alertController.preferredAction = defaultAction

        present(alertController, animated: true)
    }
}

extension SelectAddressInfoViewController: HasStoryBoardIdentifier {
    static let storyboardIdentifier = "SelectAddressInfoViewController"
}
