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

final class MainViewController: ViewController, NotificationCenterObserver {

    @IBOutlet private var protectView: UIView!
    @IBOutlet private var symptomesView: UIView!
    @IBOutlet private var emergencyButton: UIButton!
    @IBOutlet private var diagnosedButton: UIButton!
    @IBOutlet private var quarantineView: UIView!
    @IBOutlet private var statsView: UIView!

    // MARK: services
    @IBOutlet private weak var servicesButton: UIButton!
    @IBOutlet private weak var servicesLabel: UILabel!
    @IBOutlet private weak var serviceStatusView: UIView!
    @IBOutlet private weak var serviceInfoIcon: UIImageView!

    private let networkService = CovidService()
    private var observer: DefaultsDisposable?
    private var quarantineObserver: DefaultsDisposable?

    private let bluetoothServiceData = ServiceStatusData.bluetooth

    var notificationTokens: [NotificationToken] = []

    deinit {
        unobserveNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if Defaults.didRunApp {
            registerForPushNotifications()
        }

        tabBarController?.view.backgroundColor = view.backgroundColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerUser()
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
        updateServiceView()
        observeNotifications()
        showPermissionAlertIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        observer?.dispose()
        quarantineObserver?.dispose()
        unobserveNotifications()

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

        let borderColor = UIColor(red: 217 / 255.0,
                                  green: 221 / 255.0,
                                  blue: 237 / 255.0,
                                  alpha: 1.0)
        servicesButton.setCornerRadius(radius: 18, borderColor: borderColor, borderWidth: 1)
    }

    private func observeNotifications() {
        observeNotification(withName: .bluetoothStatusHasChanged) { [weak self] _ in
            self?.updateServiceView()
        }
    }
 
    @IBAction private func didTapOnServicesView(_ sender: Any) {
        guard Permissions.isBluetoothEnabled == false else { return }
        performSegue(.showServicesStatusView)
    }

    private func updateServiceView() {
        let isEnabled = Permissions.isBluetoothEnabled
        serviceStatusView.backgroundColor = isEnabled ? UIColor.tealish : UIColor.rosyPink
        servicesLabel.text = isEnabled ? "Skenovanie okolia aktívne" : "Objavil sa problém"
        serviceInfoIcon.isHidden = isEnabled
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
                self?.showPermissionAlertIfNeeded()
            }
        }
        present(welcomeViewController!, animated: false, completion: nil)
    }

    // MARK: Permissions

    private func showPermissionAlertIfNeeded() {
        guard Defaults.didRunApp else { return }

        let permissions = Permissions.shared.requiredPermissions.filter { !$0.isAuthorized }
        guard permissions.isEmpty == false else { return }
        let controller = SPPermissions.dialog(permissions)

        // Ovveride texts in controller
        controller.titleText = "Služby"
        controller.headerText = ""
        controller.footerText = ""

        controller.delegate = self

        // Always use this method for present
        controller.present(on: self)
    }

    private func registerForPushNotifications() {
        Permissions.shared.requestAuthorization(for: .notification) {}
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
            if Defaults.FCMToken == nil {
                observer = Defaults.observe(\.FCMToken) { _ in
                    DispatchQueue.main.async {
                        action()
                    }
                }
            }
        }
    }
}

extension MainViewController: SPPermissionsDelegate {

    func didAllow(permission: SPPermission) {
        print("")
    }

    func didDenied(permission: SPPermission) {
        print("")
    }

    func didHide(permissions ids: [Int]) {
        Permissions.shared.didAskForPermissions = true
        if !Defaults.didShowForeignAlert {
            performSegue(.foreignAlert)
        }
    }

    func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
        SPPermissionDeniedAlertData()
    }

}
