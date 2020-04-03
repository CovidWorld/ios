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
//  ViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 09/03/2020.
//

import UIKit
import CoreLocation
import CoreBluetooth
import SwiftyUserDefaults
import FirebaseRemoteConfig

final class MainViewController: UIViewController, NotificationCenterObserver {

    @IBOutlet private var protectView: UIView!
    @IBOutlet private var symptomesView: UIView!
    @IBOutlet private var emergencyButton: UIButton!
    @IBOutlet private var diagnosedButton: UIButton!
    @IBOutlet private var quarantineView: UIView!
    @IBOutlet private var statsView: UIView!

    private let networkService = CovidService()
    private var observer: DefaultsDisposable?
    private var quarantineObserver: DefaultsDisposable?

    private var faceCaptureCoordinator: FaceCaptureCoordinator?
    var notificationTokens: [NotificationToken] = []

    deinit {
        unobserveNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        observeFaceIDRegistrationNotification()

        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
            DispatchQueue.main.async {
                if !Defaults.didShowForeignAlert {
                    self?.performSegue(withIdentifier: "foreignAlert", sender: nil)
                }
            }
        }

        tabBarController?.view.backgroundColor = view.backgroundColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerUser()

        startFaceIDVerificationIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quarantineView?.isHidden = !Defaults.quarantineActive
        statsView?.isHidden = Defaults.quarantineActive
        diagnosedButton?.isHidden = Defaults.quarantineActive
        quarantineObserver = Defaults.observe(\.quarantineActive) { [quarantineView, diagnosedButton, statsView] update in
            DispatchQueue.main.async {
                quarantineView?.isHidden = !(update.newValue ?? true)
                statsView?.isHidden = update.newValue ?? false
                diagnosedButton?.isHidden = update.newValue ?? false
            }
        }
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        observer?.dispose()
        quarantineObserver?.dispose()

        navigationController?.isNavigationBarHidden = false
    }

    override func loadView() {
        super.loadView()
        emergencyButton.isHidden = false

        protectView.layer.cornerRadius = 20
        protectView.layer.masksToBounds = true
        symptomesView.layer.cornerRadius = 20
        symptomesView.layer.masksToBounds = true
        protectView.layer.cornerRadius = 20
        protectView.layer.masksToBounds = true
        emergencyButton.layer.cornerRadius = 20
        emergencyButton.layer.masksToBounds = true
        diagnosedButton.layer.cornerRadius = 20
        diagnosedButton.layer.masksToBounds = true

        diagnosedButton.titleLabel?.textAlignment = .center
    }

    @IBAction private func emergencyDidTap(_ sender: Any) {
        var emergencyNumber = "0800221234"
        if let configValue = remoteConfigValue()?.jsonValue as? [String: Any],
            let strNumber = configValue["SK"] as? String,
            !strNumber.isEmpty {
            // user started the app offline and RemoteConfig has not been fetched
            emergencyNumber = strNumber
        }

        guard let number = URL(string: "tel://\(emergencyNumber)") else { return }
        UIApplication.shared.open(number)
    }
}

// MARK: - Private
extension MainViewController {

    private func remoteConfigValue() -> RemoteConfigValue? {
        Firebase.remoteConfig?.configValue(forKey: "hotlines")
    }

    private func registerUser() {
        if Defaults.profileId == nil {
            let action = { [weak self] in
                let data = RegisterProfileRequestData()
                self?.networkService.registerUserProfile(profileRequestData: data) { (result) in
                    switch result {
                    case .success(let profile):
                        Defaults.profileId = profile.profileId
                        DispatchQueue.main.async {
                            BeaconManager.shared.advertiseDevice(beacon: BeaconId(id: UInt32(profile.profileId)))
                            BeaconManager.shared.startMonitoring()
                        }
                    case .failure: break
                    }
                }
            }

            action()
            if Defaults.pushToken == nil {
                observer = Defaults.observe(\.pushToken) { _ in
                    DispatchQueue.main.async {
                        action()
                    }
                }
            }
        }
    }
}

extension MainViewController {

    // MARK: FaceID Flow

    func observeFaceIDRegistrationNotification() {
        observeNotification(withName: .startFaceIDRegistration) { [weak self] (notification) in
            let navigationController = StartFaceIDRegistrationNotification.navigationController(from: notification)
            let completion = StartFaceIDRegistrationNotification.completion(from: notification)

            if let navigationController = navigationController, let completion = completion {
                self?.showFaceRegistration(in: navigationController, completion: completion)
            }
        }
    }

    private func showFaceRegistration(in navigationController: UINavigationController, completion: @escaping () -> Void) {
        faceCaptureCoordinator = FaceCaptureCoordinator(useCase: .registerFace)
        faceCaptureCoordinator?.onCoordinatorResolution = { [weak self] result in
            switch result {
            case .success:
                self?.faceCaptureCoordinator = nil
                self?.navigationController?.popToRootViewController(animated: true)
            case .failure:
                break
            }

            completion()
        }
        faceCaptureCoordinator?.showOnboarding(in: navigationController)
    }

    private func showFaceVerification() {
        faceCaptureCoordinator = FaceCaptureCoordinator(useCase: .verifyFace)
        let viewController = faceCaptureCoordinator!.startFaceCapture()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        faceCaptureCoordinator?.navigationController = navigationController

        faceCaptureCoordinator?.onAlert = { alertControler in
            navigationController.present(alertControler, animated: true, completion: nil)
        }
        faceCaptureCoordinator?.onCoordinatorResolution = { _ in
            navigationController.dismiss(animated: true, completion: nil)
        }
        present(navigationController, animated: true, completion: nil)
    }

    // TODO: remove this func and key from Settings.bundle once the feature is ready
    private func startFaceIDVerificationIfNeeded() {

        guard
            Defaults.quarantineActive == true,
            FaceIDStorage().referenceFaceData != nil,
            Defaults.allowVerifyFaceId == true else {
            return
        }
        after(.seconds(1)) { [weak self] in
            self?.showFaceVerification()
        }
    }
}
