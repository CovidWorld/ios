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
import AVFoundation

extension MainViewController: HasStoryBoardIdentifier {
    static let storyboardIdentifier = "MainViewController"
}

final class MainViewController: ViewController, NotificationCenterObserver {

    @IBOutlet private var protectView: UIView!
    @IBOutlet private var symptomesView: UIView!
    @IBOutlet private var emergencyButton: UIButton!
    @IBOutlet private var actionButton: UIButton!
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
        if Defaults.didRunApp {
            registerForPushNotifications()
        }

        if Defaults.profileId == nil {
            registerUser()
        }

        tabBarController?.view.backgroundColor = view.backgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = true
        updateView()
        showWelcomeScreenIfNeeded()

        quarantineObserver = Defaults.observe(\.quarantineEnd) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateView()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
        actionButton.layer.cornerRadius = 20
        actionButton.layer.masksToBounds = true

        actionButton.titleLabel?.textAlignment = .center
    }

    func showQuarantineRegistration() {
        guard let importantViewController = UIStoryboard.controller(ofType: SelectAddressInfoViewController.self) else { return }

        importantViewController.onContinue = {
            importantViewController.performSegue(withIdentifier: "showCountryCode", sender: nil)
        }
        navigationController?.pushViewController(importantViewController, animated: true)
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
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .notDetermined {
                current.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
                    DispatchQueue.main.async {
                        if !Defaults.didShowForeignAlert {
                           self?.performSegue(.foreignAlert)
                        }
                    }
                }
            }
            // TODO: handle other cases
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    @IBAction private func didTapQuarantine(_ sender: Any) {
        if Defaults.quarantineActive {
            startRandomCheck(showInfo: true)
        } else {
            showQuarantineRegistration()
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
    private func updateView() {
        let showQuarantine = Defaults.quarantineActive || (Defaults.covidPass != nil && (Defaults.quarantineStart ?? Date(timeIntervalSinceNow: 10)) > Date() )
        quarantineView?.isHidden = !showQuarantine
        statsView?.isHidden = showQuarantine
        actionButton?.isHidden = Defaults.covidPass != nil && (Defaults.quarantineStart == nil || (Defaults.quarantineStart ?? Date()) >= Date())

        if Defaults.quarantineActive == false {
            actionButton.setTitle("Bol som v zahraničí alebo\nmusím zostať v karanténe", for: .normal)
            actionButton.backgroundColor = UIColor(red: 80.0 / 255.0, green: 88.0 / 255.0, blue: 249.0 / 255.0, alpha: 1.0)
        } else if Defaults.quarantineStart != nil {
            actionButton.setTitle("Overiť sa v mieste karantény", for: .normal)
            actionButton.backgroundColor = UIColor(red: 241.0 / 255.0, green: 106.0 / 255.0, blue: 195.0 / 255.0, alpha: 1.0)
        }
    }

    private func registerUser() {
        let action = { [weak self] in
            let data = RegisterProfileRequestData()
            self?.networkService.registerUserProfile(profileRequestData: data) { [weak self] (result) in
                switch result {
                case .success(let profile):
                    Defaults.profileId = profile.profileId
                case .failure:
                    Alert.show(title: "Chyba",
                               message: "Pri registrácií došlo k chybe",
                               defaultTitle: "Skúsiť znovu") { (_) in
                                self?.registerUser()
                    }
                }
            }
        }

        if Defaults.FCMToken == nil {
            observer = Defaults.observe(\.FCMToken) { _ in
                DispatchQueue.main.async {
                    action()
                }
            }
        } else {
            action()
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

        observeNotification(withName: .startRandomCheck) { [weak self] _ in
            self?.startRandomCheck()
        }
    }

    private func showFaceRegistration(in navigationController: UINavigationController, completion: @escaping () -> Void) {
        faceCaptureCoordinator = FaceCaptureCoordinator(useCase: .registerFace)
        faceCaptureCoordinator?.onAlert = { alertControler in
            navigationController.present(alertControler, animated: true, completion: nil)
        }
        faceCaptureCoordinator?.onCoordinatorResolution = { [weak self] result in
            guard let self = self else { return }

            self.finishProfileRegistration { [weak self] in
                switch result {
                case .success:
                    self?.faceCaptureCoordinator = nil
                    self?.navigationController?.popToRootViewController(animated: true)
                    completion()

                case .failure:
                    break
                }
            }
        }

        let cameraAccess = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        let authorizationStatus = CLLocationManager.authorizationStatus()
        let isAuthorized = authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
        let locationAccess = CLLocationManager.locationServicesEnabled() && isAuthorized

        if cameraAccess && locationAccess {
            faceCaptureCoordinator?.showOnboarding(in: navigationController)
        } else {
            guard let importantViewController = UIStoryboard.controller(ofType: SelectAddressInfoViewController.self) else { return }
            importantViewController.onContinue = {
                self.faceCaptureCoordinator?.showOnboarding(in: navigationController)
            }
            navigationController.pushViewController(importantViewController, animated: true)
        }
    }

    private func finishProfileRegistration(_ completion: @escaping () -> Void) {
        observer?.dispose()
        observer = Defaults.observe(\.noncePush) { [weak self] update in
            DispatchQueue.main.async {
                guard let nonceValue = update.newValue, let nonce = nonceValue  else {
                    completion()
                    return
                }
                self?.networkService.updateUserProfileNonce(profileRequestData: BasicWithNonceRequestData(nonce: nonce)) { (result) in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            completion()
                        }
                        return
                    case .failure:
                        Alert.show(title: "Chyba",
                                   message: "Pri registrácií došlo k chybe. Skúste znovu.",
                                   cancelAction: { (_) in
                                        DispatchQueue.main.async {
                                            completion()
                                        }
                        })
                    }
                }
            }
        }

        networkService.requestNoncePush(nonceRequestData: BasicRequestData()) { (result) in
            switch result {
            case .success: break //wait for silent push
            case .failure:
                Alert.show(title: "Chyba",
                           message: "Pri registrácií došlo k chybe. Skúste znovu.",
                           cancelAction: { (_) in
                                DispatchQueue.main.async {
                                    completion()
                                }
                })
            }
        }
    }

    private func showFaceVerification(in navigationController: UINavigationController) {
        guard faceCaptureCoordinator == nil else {
            print("face coordinator is active, skipping..")
            return
        }

        faceCaptureCoordinator = FaceCaptureCoordinator(useCase: .verifyFace)
        let viewController = faceCaptureCoordinator!.startFaceCapture()
        faceCaptureCoordinator?.navigationController = navigationController

        faceCaptureCoordinator?.onAlert = { alertControler in
            navigationController.present(alertControler, animated: true, completion: nil)
        }
        faceCaptureCoordinator?.onCoordinatorResolution = { [weak self] faceResult in
            switch faceResult {
            case .success(let success):
                if success {
                    let locationCheck = LocationMonitoring.shared.verifyQuarantinePresence()
                    self?.networkService.requestNonce(nonceRequestData: BasicRequestData()) { [weak self] (result) in
                        switch result {
                        case .success(let data):
                            var status = "LEFT"
                            if locationCheck {
                                status = "OK"
                            }
                            self?.networkService.requestPresenceCheck(presenceCheckRequestData: PresenceCheckRequestData(status: status, nonce: data.nonce)) { [weak self] (_) in
                                switch result {
                                case .success:
                                    DispatchQueue.main.async {
                                        self?.dismiss(animated: true, completion: {
                                            self?.faceCaptureCoordinator = nil
                                        })
                                    }
                                    return
                                case .failure:
                                    self?.onError()
                                }
                            }
                        case .failure:
                            self?.onError()
                        }
                    }
                }
            case .failure:
                self?.onError()
            }
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    func onError() {
        Alert.show(title: "Chyba",
                   message: "Pri overovaní dodržiavania karantény došlo k chybe. Skúste zopakovať overenie znovu.",
                   cancelAction: { (_) in
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: {
                                self.faceCaptureCoordinator = nil
                            })
                        }
        })
    }

    func startRandomCheck(showInfo: Bool = false) {
        guard FaceIDStorage().referenceFaceData != nil, Defaults.quarantineActive else { return }

        actionButton.isEnabled = false
        networkService.requestPresenceCheckNeeded(presenceNeededRequestData: BasicRequestData()) { [weak self] (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    if data.isPresenceCheckPending {
                        guard let viewController = UIStoryboard.controller(ofType: SelectAddressInfoViewController.self) else {
                            assertionFailure("this controller should exist")
                            return
                        }

                        let navigationController = UINavigationController(rootViewController: viewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        viewController.onContinue = { [weak self] in
                            self?.showFaceVerification(in: navigationController)
                        }
                        self?.present(navigationController, animated: true, completion: nil)
                    } else if showInfo {
                        guard let viewController = UIStoryboard.controller(ofType: NoRandomCheckViewController.self) else {
                            assertionFailure("this controller should exist")
                            return
                        }

                        let navigationController = UINavigationController(rootViewController: viewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        self?.present(navigationController, animated: true, completion: nil)
                    }
                    self?.actionButton.isEnabled = true
                }
                return
            case .failure: break
            }
            DispatchQueue.main.async {
                self?.actionButton.isEnabled = true
            }
        }
    }
}
