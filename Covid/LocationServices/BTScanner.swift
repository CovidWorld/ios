//
//  BTScanner.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BTScannering: class {

    var delegate: BTScannerDelegate? { get set }
    
    var isRunning: Bool { get }
    func start()
    func stop()

}

protocol BTScannerDelegate: class {
    func didFound(device: CBPeripheral, RSSI: Int)
    func didUpdate(device: CBPeripheral, RSSI: Int)

    func didReadData(for device: CBPeripheral, data: Data)
}

protocol BTScannerStoreDelegate: class {
    func didFind(device: CBPeripheral, rssi: Int)
}

final class BTScanner: NSObject, BTScannering, CBCentralManagerDelegate, CBPeripheralDelegate {

    var filterRSSIPower: Bool = false
    private let allowedRSSIRange: ClosedRange<Int> = -90...0

    private var centralManager: CBCentralManager! = nil
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private var discoveredData: [UUID: Data] = [:]

    private let acceptUUIDs = [BT.broadcastCharacteristic.cbUUID, BT.transferCharacteristic.cbUUID]
    
    var scannerStoreDelegate: BTScannerStoreDelegate?

    override init() {
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)

        if #available(iOS 13.1, *) {
            if ![CBManagerAuthorization.allowedAlways, .restricted].contains(CBCentralManager.authorization) {
                print("BTScanner: Not authorized! \(CBCentralManager.authorization)")
                return
            }
        } else if #available(iOS 13.0, *) {
            if ![CBManagerAuthorization.allowedAlways, .restricted].contains(centralManager.authorization) {
                print("BTScanner: Not authorized! \(centralManager.authorization)")
                return
            }
        }
    }

    // MARK: - BTScannering

    weak var delegate: BTScannerDelegate?

    var isRunning: Bool {
        return centralManager.isScanning
    }
    private var started: Bool = false

    func start() {
        started = true
        guard !centralManager.isScanning, centralManager.state == .poweredOn else { return }

        centralManager.scanForPeripherals(
            withServices: [BT.transferService.cbUUID],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
        )
        print("BTScanner: Scanning started")
    }

    func stop() {
        started = false
        guard centralManager.isScanning else { return }

        centralManager.stopScan()
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BTScanner: centralManagerDidUpdateState: \(central.state.rawValue)")

        guard central.state == .poweredOn else { return }

        guard started else { return }
        start()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard discoveredPeripherals[peripheral.identifier] == nil else {
            // already registred
            print("BTScanner: Update ID: \(peripheral.identifier.uuidString) at \(RSSI)")
            delegate?.didUpdate(device: peripheral, RSSI: RSSI.intValue)
            return
        }
        print("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")
        delegate?.didFound(device: peripheral, RSSI: RSSI.intValue)
        scannerStoreDelegate?.didFind(device: peripheral, rssi: RSSI.intValue)

        discoveredPeripherals[peripheral.identifier] = peripheral
        discoveredData[peripheral.identifier] = Data()

        if filterRSSIPower {
            guard allowedRSSIRange.contains(RSSI.intValue) else {
                print("BTScanner: RSSI range \(RSSI.intValue)")
                return
            }
        }
        print("BTScanner: Char \(String(describing: peripheral.services))")

        print("BTScanner: Connecting to peripheral \(peripheral)")
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("BTScanner: Failed to connect to \(peripheral), error: \(error?.localizedDescription ?? "none")")

        cleanup(peripheral)
        discoveredPeripherals.removeValue(forKey: peripheral.identifier)
    }

    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("BTScanner: connectionEventDidOccur \(peripheral), event: \(event)")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BTScanner: Peripheral connected \(peripheral)")

        peripheral.delegate = self
        peripheral.discoverServices([BT.transferService.cbUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("BTScanner: didDisconnectPeripheral: \(peripheral), error: \(error?.localizedDescription ?? "none")")

        cleanup(peripheral)
        discoveredPeripherals.removeValue(forKey: peripheral.identifier)
    }

    // MARK: CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("BTScanner: Error discovering services: \(String(describing: error?.localizedDescription))")
            cleanup()
            return
        }

        // Discover the characteristic we want...
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let services = peripheral.services, !services.isEmpty else {
            print("BTScanner: No services to discover")
            return
        }

        services.forEach {
            peripheral.discoverCharacteristics([BT.broadcastCharacteristic.cbUUID], for: $0) // transferCharacteristic
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("BTScanner: Error discovering characteristics \(String(describing: error?.localizedDescription))")
            cleanup()
            return
        }

        guard let characteristics = service.characteristics else {
            print("BTScanner: No characteristics to subscribe")
            return
        }

        for characteristic in characteristics where acceptUUIDs.contains(characteristic.uuid) {
            print("BTScanner: readValue for \(characteristic.uuid)")
            peripheral.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("BTScanner: Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        guard let newData = characteristic.value else {
            print("BTScanner: No data in characteristic")
            return
        }

        let stringFromData = String(data: newData, encoding: .utf8)
        delegate?.didReadData(for: peripheral, data: newData)

        peripheral.setNotifyValue(false, for: characteristic)
        centralManager.cancelPeripheralConnection(peripheral)
        print("BTScanner: Received: \(stringFromData ?? "none")")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("BTScanner: Error changing notification state: \(String(describing: error?.localizedDescription))")
            return
        }

        guard acceptUUIDs.contains(characteristic.uuid) else {
            print("BTScanner: Error not accepted characteristic: \(characteristic)")
            return
        }

        if characteristic.isNotifying {
            print("BTScanner: Notification began on \(characteristic)")
        } else {
            print("BTScanner: Notification stoppped on \(characteristic). Disconnecting")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

}

private extension BTScanner {

    func cleanup() {
        for peripheral in discoveredPeripherals {
            cleanup(peripheral.value)
        }
        discoveredPeripherals = [:]
        discoveredData = [:]
    }

    func cleanup(_ peripheral: CBPeripheral) {
        // Don't do anything if we're not connected
        // See if we are subscribed to a characteristic on the peripheral
        guard peripheral.state == .connected, let services = peripheral.services else { return }

        for service in services where service.characteristics != nil {
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics where acceptUUIDs.contains(characteristic.uuid) {
                guard !characteristic.isNotifying else { return }
                peripheral.setNotifyValue(false, for: characteristic)
            }
        }
    }

}
