//
//  ViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 09/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import SwiftyUserDefaults
import FirebaseRemoteConfig
import SwiftyUserDefaults

class MainViewController: UIViewController {

    @IBOutlet var protectView: UIView!
    @IBOutlet var symptomsView: UIView!
    @IBOutlet var emergencyButton: UIButton!
    @IBOutlet var diagnosedButton: UIButton!
    @IBOutlet var quarantineView: UIView!
    
    private let networkService = CovidService()
    private var observer: DefaultsDisposable?
    private var quarantineObserver: DefaultsDisposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { [weak self] didAllow, error in
            DispatchQueue.main.async {
                if !Defaults.didShowForeignAlert {
                    self?.performSegue(withIdentifier: "foreignAlert", sender: nil)
                }
            }
        })
        
        registerUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        BeaconManager.shared.startMonitoring()
        BeaconManager.shared.advertiseDevice()
        if Defaults.quarantineActive {
            LocationTracker.shared.startLocationTracking()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quarantineView?.isHidden = !Defaults.quarantineActive
        diagnosedButton?.isHidden = Defaults.quarantineActive
        quarantineObserver = Defaults.observe(\.quarantineActive) { [quarantineView, diagnosedButton] update in
            DispatchQueue.main.async {
                quarantineView?.isHidden = !(update.newValue ?? true)
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
        symptomsView.layer.cornerRadius = 20
        symptomsView.layer.masksToBounds = true
        emergencyButton.layer.cornerRadius = 20
        emergencyButton.layer.masksToBounds = true
        diagnosedButton.layer.cornerRadius = 20
        diagnosedButton.layer.masksToBounds = true
        
        diagnosedButton.titleLabel?.textAlignment = .center
    }

    @IBAction func emergencyDidTap(_ sender: Any) {
        var emergencyNumber = Defaults.emergencyNumber
        if let configValue = remoteConfigValue(),
            let json = configValue.jsonValue as? [String: Any],
            let strNumber = json["SK"] as? String,
            !strNumber.isEmpty {
            // user started the app offline and RemoteConfig has not been fetched
            emergencyNumber = strNumber
        } else {
            Defaults.needsFetchRemoteConfig = true
        }

        guard let number = URL(string: "tel://\(emergencyNumber)") else { return }
        UIApplication.shared.open(number)
    }
}

//MARK: - Private
extension MainViewController {

    private func remoteConfigValue() -> RemoteConfigValue? {
        return (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?.configValue(forKey: "hotlines")
    }

    private func registerUser() {
        if Defaults.profileId == nil {
            let action = { [weak self] in
                let data = RegisterProfileRequestData()
                self?.networkService.registerUserProfile(profileRequestData: data) { (result) in
                    switch result {
                    case .success(let profile):
                        Defaults.profileId = profile.profileId
                    case .failure: break
                    }
                }
            }
            
            if Defaults.pushToken != nil {
                action()
            } else {
                observer = Defaults.observe(\.pushToken) { _ in
                    DispatchQueue.main.async {
                        action()
                    }
                }
            }
        }
    }
}
