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

extension MainViewController: HasStoryBoardIdentifier {
    static let storyboardIdentifier = "MainViewController"
}

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
        navigationController?.isNavigationBarHidden = true

        quarantineObserver = Defaults.observe(\.quarantineActive) { [quarantineView, diagnosedButton, statsView] update in
            DispatchQueue.main.async {
                quarantineView?.isHidden = !(update.newValue ?? true)
                statsView?.isHidden = update.newValue ?? false
                diagnosedButton?.isHidden = update.newValue ?? false
            }
        }

        showWelcomeScreenIfNeeded()
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

    // MARK: Welcome screen

    private func showWelcomeScreenIfNeeded() {
        guard !Defaults.didRunApp else { return }

        let welcomeViewController = UIStoryboard.controller(ofType: WelcomeViewController.self)
        welcomeViewController?.modalPresentationStyle = .fullScreen
        welcomeViewController?.onAgree = {
            Defaults.didRunApp = true
            welcomeViewController?.dismiss(animated: true) { [weak self] in
                self?.registerForPushNotifications()
            }
        }
        present(welcomeViewController!, animated: false, completion: nil)
    }

    // MARK: Permissions

    private func registerForPushNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
            DispatchQueue.main.async {
                if !Defaults.didShowForeignAlert {
                    self?.performSegue(.foreignAlert)
                }
            }
        }
    }

    @IBAction private func emergencyDidTap(_ sender: Any) {
        let emergencyNumber = Firebase.remoteDictionaryValue(for: .hotlines)["SK"] as? String ?? ""
        guard let number = URL(string: "tel://\(emergencyNumber)") else { return }
        UIApplication.shared.open(number)
    }
}

// MARK: - Private
extension MainViewController {

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

    private func observeFaceIDRegistrationNotification() {
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
            guard let self = self else { return }

            self.registerForQuarantine { [weak self] in
                switch result {
                case .success:
                    self?.faceCaptureCoordinator = nil
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure:
                    break
                }
                completion()
            }
        }
        faceCaptureCoordinator?.showOnboarding(in: navigationController)
    }

    private func registerForQuarantine(_ completion: @escaping () -> Void) {
        // Call only if we're registering
//        let data = QuarantineRequestData(mfaToken: Defaults.mfaToken)
//        networkService.requestQuarantine(quarantineRequestData: data) { (result) in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    LocationTracker.shared.startLocationTracking()
//
//                case .failure:
//                    break
//                }
//                completion()
//            }
//        }
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
