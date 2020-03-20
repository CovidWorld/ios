//
//  BTAdvertiser.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BTAdvertising: class {

    var isRunning: Bool { get }
    func start()
    func stop()

    @available(iOS 13.0, *)
    var authorization: CBManagerAuthorization { get }
    
}

final class BTAdvertiser: NSObject, BTAdvertising, CBPeripheralManagerDelegate {

    private var peripheralManager: CBPeripheralManager! = nil

    private var serviceBroadcast: CBCharacteristic?
    private var uniqueBroadcast: CBCharacteristic?

    @available(iOS 13.0, *)
    var authorization: CBManagerAuthorization {
        if #available(iOS 13.1, *) {
            return CBPeripheralManager.authorization
        } else if #available(iOS 13.0, *) {
            return peripheralManager.authorization
        } else {
            return .allowedAlways
            //return peripheralManager.authorizationStatus
        }
    }

    override init() {
        super.init()

        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: [
                CBPeripheralManagerOptionShowPowerAlertKey: true, // ask to turn on bluetooth
                CBPeripheralManagerOptionRestoreIdentifierKey: true
            ]
        )

        if #available(iOS 13.1, *) {
            if ![CBManagerAuthorization.allowedAlways, .restricted].contains(CBPeripheralManager.authorization) {
                print("BTAdvertiser: Not authorized! \(CBPeripheralManager.authorization)")
                return
            }
        } else if #available(iOS 13.0, *) {
            if ![CBManagerAuthorization.allowedAlways, .restricted].contains(peripheralManager.authorization) {
                print("BTAdvertiser: Not authorized! \(peripheralManager.authorization)")
                return
            }
        }
    }

    // MARK: - BTAdvertising

    var isRunning: Bool {
        return peripheralManager.isAdvertising
    }
    private var started: Bool = false

    func start() {
        started = true
        guard !isRunning, peripheralManager.state == .poweredOn else { return }

        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: BT.advertiserName.rawValue,
            CBAdvertisementDataServiceUUIDsKey : [BT.transferService.cbUUID]
        ])

        print("BTAdvertiser: started")
    }

    func stop() {
        started = false
        guard isRunning else { return }

        peripheralManager.stopAdvertising()

        print("BTAdvertiser: stoped")
    }

    // MARK: CBPeripheralManagerDelegate

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Opt out from any other state
        if peripheral.state != .poweredOn {
            print("BTAdvertiser: peripheralManager state \(peripheral.state)")
            return
        }

        print("BTAdvertiser: peripheralManager powered on")

        let serviceBroadcast = CBMutableCharacteristic(
            type: BT.transferCharacteristic.cbUUID,
            properties: .read,
            value: (UserDefaults.standard.string(forKey: "BUID") ?? "").data(using: .utf8), // ID device according to BE spec
            permissions: .readable
        )
        self.serviceBroadcast = serviceBroadcast

        let uniqueBroadcast = CBMutableCharacteristic(
              type: BT.broadcastCharacteristic.cbUUID,
              properties: .read,
              value: BTDeviceName.data(using: .utf8),
              permissions: .readable
        )
        self.uniqueBroadcast = uniqueBroadcast

        let transferService = CBMutableService(type: BT.transferService.cbUUID, primary: true)
        transferService.characteristics = [serviceBroadcast, uniqueBroadcast]

        peripheralManager.add(transferService)

        guard started else { return }
        start()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("BTAdvertiser: willRestoreState, dict: \(dict)")
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("BTAdvertiser: peripheralManagerDidStartAdvertising, error: \(error?.localizedDescription ?? "none")")
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("BTAdvertiser: peripheralManagerIsReady")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("BTAdvertiser: subscribed to characteristic \(characteristic)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("BTAdvertiser: unsubscribed to characteristic \(characteristic)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("BTAdvertiser: didAddService: \(service), error: \(error?.localizedDescription ?? "none")")
    }


    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("BTAdvertiser: didReceiveRead: \(request)")

        let characteristic: CBCharacteristic

        if let uniqueBroadcast = uniqueBroadcast, request.characteristic.uuid == uniqueBroadcast.uuid {
            characteristic = uniqueBroadcast
        } else if let serviceBroadcast = serviceBroadcast, request.characteristic.uuid == serviceBroadcast.uuid {
            characteristic = serviceBroadcast
        } else {
            peripheralManager.respond(to: request, withResult: .attributeNotFound)
            return
        }

        guard let value = characteristic.value, request.offset <= value.count else {
            peripheralManager.respond(to: request, withResult: .invalidOffset)
            return
        }

        let range = request.offset...(value.count - request.offset)
        request.value = characteristic.value?.subdata(in: range.lowerBound..<range.upperBound)
        peripheral.respond(to: request, withResult: .success)
    }

}
