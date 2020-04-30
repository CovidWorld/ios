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
//  ServicesStatusViewController.swift
//  Covid
//
//  Created by Boris Bielik on 26/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit
import Reachability

final class ServicesStatusViewController: ViewController, NotificationCenterObserver {

    @IBOutlet weak var tableView: UITableView!

    private var reachability: Reachability?
    var notificationTokens: [NotificationToken] = []

    let datasource: [ServiceStatusData] = [.bluetooth,
                                           .gps,
                                           .deviceConnectivity]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachability?.stopNotifier()
        reachability = try? Reachability()
        reachability?.whenReachable = { [weak self] _ in
            self?.reloadData()
        }
        reachability?.whenUnreachable = { [weak self] _ in
            self?.reloadData()
        }
        try? reachability?.startNotifier()

        reloadData()
        observeNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unobserveNotifications()
    }

    private func observeNotifications() {
        observeNotification(withName: .locationAuthorizationStatusHasChanged) { [weak self] _ in
            self?.reloadData()
        }

        observeNotification(withName: .bluetoothStatusHasChanged) { [weak self] _ in
            self?.reloadData()
        }
    }

    private func reloadData() {
        tableView.reloadData()
    }

    func status(for data: ServiceStatusData) -> ServiceStatusData.ServiceStatus {
        switch data {
        case .bluetooth:
            return Permissions.isBluetoothEnabled ? .on : .off
        case .gps:
            return Permissions.isLocationEnabled ? .on : .off
        case .deviceConnectivity:
            guard let reachability = reachability else {
                return .off
            }

            return reachability.connection != .unavailable ? .on : .off
        }
    }

}

extension ServicesStatusViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { datasource.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: ServiceStatusTableViewCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ServiceStatusTableViewCell else { return UITableViewCell() }

        let data = datasource[indexPath.row]
        let status = self.status(for: data)
        cell.titleLabel.attributedText = data.attributedString(for: status)
        cell.permissionView.setIcon(data.icon, text: data.statusString(for: status))
        cell.permissionView.backgroundColor = data.color(for: status)

        cell.onAction = { [weak self] in
            self?.resolveAction(for: data)
        }
        cell.selectionStyle = .none

        return cell
    }
}

extension ServicesStatusViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datasource[indexPath.row]
        resolveAction(for: data)
    }
}

extension ServicesStatusViewController {

    func resolveAction(for data: ServiceStatusData) {
        guard status(for: data) == .off else { return }

        switch data {
        case .bluetooth:
            Permissions.shared.request(for: .bluetooth) {
                BeaconManager.shared.restart()
            }

        case .gps:
            Permissions.shared.requestAuthorization(for: .locationAlwaysAndWhenInUse) { [weak self] in
                self?.tableView.reloadData()
            }
        case .deviceConnectivity:
            break
        }
    }
}
