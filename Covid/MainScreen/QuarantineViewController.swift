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
//  QuarantineViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 16/03/2020.
//

import UIKit
import SwiftyUserDefaults

extension Notification.Name {
    static let updateQuarantine = Notification.Name("sk.nczi.ekarantena.updateQuarantine")
}

final class QuarantineViewController: ViewController {
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var quarantineUntilLabel: UILabel!
    @IBOutlet private var countdownNoticeLabel: UILabel!

    private let networkService = CovidService()

    private var quarantineData: QuarantineStatusResponseData? {
        didSet {
            if let start = quarantineData?.quarantineStart,
                let end = quarantineData?.quarantineEnd {
                Defaults.quarantineActive = (start < Date() && end > Date())
            } else {
                Defaults.quarantineActive = false
            }
            Defaults.quarantineStart = quarantineData?.quarantineStart
            Defaults.quarantineEnd = quarantineData?.quarantineEnd
            Defaults.borderCrossedAt = quarantineData?.borderCrossedAt

            if let address = quarantineData?.address {
                Defaults.quarantineCity = address.city != nil ? address.city : Defaults.quarantineCity
                Defaults.quarantineStreet = address.streetName != nil ? address.streetName : Defaults.quarantineStreet
                Defaults.quarantineStreetNumber = address.streetNumber != nil ? address.streetNumber : Defaults.quarantineStreetNumber
                Defaults.quarantineLatitude = address.latitude != nil ? address.latitude : Defaults.quarantineLatitude
                Defaults.quarantineLongitude = address.longitude != nil ? address.longitude : Defaults.quarantineLongitude
            }

            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard Defaults.profileId != nil else { return }

        NotificationCenter.default.addObserver(forName: .updateQuarantine, object: nil, queue: nil) { [weak self] (_) in
            self?.updateQuarantineStatus()
        }

        updateView()
        updateQuarantineStatus()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: .updateQuarantine, object: nil)
    }
}

extension QuarantineViewController {
    private func updateQuarantineStatus() {
        if Defaults.covidPass != nil {
            networkService.requestQuarantine(quarantineRequestData: BasicRequestData()) { [weak self] (result) in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        self?.quarantineData = response
                    }
                case .failure(let error):
                    if case NetworkServiceError.notConnected = error {
                        Alert.show(title: LocalizedString(forKey: "error.notConnected.title"), message: LocalizedString(forKey: "error.notConnected.message"))
                    }
                }
            }
        }
    }

    private func updateView() {
        if let endDate = Defaults.quarantineEnd, Defaults.quarantineActive == true {
            let days = Int(abs(((endDate.timeIntervalSince1970 - Date().timeIntervalSince1970) / 86400).rounded(.awayFromZero)))
            quarantineUntilLabel.text = QuarantineViewController.daysToString(days)
            quarantineUntilLabel.textColor = UIColor(red: 241.0 / 255.0, green: 106.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
        } else if Defaults.covidPass != nil && (Defaults.quarantineStart == nil || Defaults.quarantineStart ?? Date() >= Date()) {
            quarantineUntilLabel.text = LocalizedString(forKey: "quarantine.pending.title")
            quarantineUntilLabel.textColor = UIColor(red: 241.0 / 255.0, green: 160.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0)
        } else {
            quarantineUntilLabel.text = nil
        }
        updateCountdownLabel()
        addressLabel.text = "\(Defaults.quarantineStreet ?? "") \(Defaults.quarantineStreetNumber ?? "")\n\(Defaults.quarantineCity ?? "")"

        LocationMonitoring.monitorLocationIfNeeded()
    }

    private func updateCountdownLabel() {
        if let date = Defaults.quarantineStart {
            countdownNoticeLabel.text = LocalizedString(forKey: "quarantine.pending.description") + "\(date.formattedDateAndYear())"
        } else {
            countdownNoticeLabel.text = LocalizedString(forKey: "quarantine.pending.info")
        }
    }

    private static func daysToString(_ numberOfDays: Int) -> String {
        var localizedKey: String
        switch numberOfDays {
        case 1:
            localizedKey = "day"
        case _ where numberOfDays >= 2 && numberOfDays <= 4:
            localizedKey = "days"
        default:
            localizedKey = "daysMultiple"
        }
        let days = LocalizedString(forKey: localizedKey)

        return "\(numberOfDays) \(days)"
    }
}
