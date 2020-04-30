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
//  ServiceStatusData.swift
//  Covid
//
//  Created by Boris Bielik on 26/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resized(size:CGSize, scale: CGFloat? = nil) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale ?? self.scale)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

enum ServiceStatusData: CaseIterable {

    enum ServiceStatus {
        case on
        case off

        func status(for data: ServiceStatusData) -> String {
            switch self {
            case .on:
                switch data {
                case .deviceConnectivity:
                    return "Aktívne"
                default:
                    return "Povolené"
                }
            case .off:
                switch data {
                case .deviceConnectivity:
                    return "Neaktívne"
                default:
                    return "Povoliť"
                }
            }
        }
    }

    case bluetooth
    case gps
    case deviceConnectivity

    func statusString(for status: ServiceStatus) -> String {
        status.status(for: self)
    }

    func attributedString(for status: ServiceStatus) -> NSAttributedString {
        switch self {
        case .bluetooth:
            return bluetoothAttributedString(for: status)
        case .gps:
            return gpsAttributedString(for: status)
        case .deviceConnectivity:
            return deviceConnectivityAttributedString(for: status)
        }
    }

    func color(for status: ServiceStatus) -> UIColor {
        switch status {
        case .on:
            return .tealish
        case .off:
            return .lightishBlueTwo
        }
    }

    var icon: UIImage {
        switch self {
        case .bluetooth:
            return UIImage(named: "bluetooth")!
                .resized(size: CGSize(width: 10, height: 14))

        case .gps:
            return UIImage(named: "location")!
                .resized(size: CGSize(width: 10, height: 14))

        case .deviceConnectivity:
            return UIImage(named: "wifi")!
                .resized(size: CGSize(width: 16, height: 14))
        }
    }
}

// MARK: bluetooth
extension ServiceStatusData {
    private func bluetoothAttributedString(for status: ServiceStatus) -> NSAttributedString {
        let string = status == .off ? "Služba Bluetooth je vypnutá" : "Služba Bluetooth je zapnutá"
        let attributedString = NSMutableAttributedString(string: string, attributes: [
          .font: UIFont(name: "Poppins-Regular", size: 16.0)!,
          .foregroundColor: UIColor.slateGrey,
          .kern: -0.43
        ])
        attributedString.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 16.0)!, range: NSRange(location: 7, length: 9))
        return NSAttributedString(attributedString: attributedString)
    }
}

// MARK: gps
extension ServiceStatusData {
    private func gpsAttributedString(for status: ServiceStatus) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "Aplikácia má povolenie na získanie\n aktuálnej pozície - potrebné výhradne\npre korektné fungovanie bluetooth, dáta\no polohe nikdy neopustia Vaše zariadenie", attributes: [
          .font: UIFont(name: "Poppins-Regular", size: 16.0)!,
          .foregroundColor: UIColor.slateGrey,
          .kern: -0.43
        ])
        attributedString.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 16.0)!, range: NSRange(location: 36, length: 17))
        return NSAttributedString(attributedString: attributedString)
    }
}

// MARK: device connectivity

extension ServiceStatusData {
    private func deviceConnectivityAttributedString(for status: ServiceStatus) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "Máte prístup k inernetu - aspoň\nobčasne napr. WiFi alebo mobilné dáta", attributes: [
          .font: UIFont(name: "Poppins-Regular", size: 16.0)!,
          .foregroundColor: UIColor.slateGrey,
          .kern: -0.43
        ])
        attributedString.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 16.0)!, range: NSRange(location: 46, length: 4))
        attributedString.addAttribute(.font, value: UIFont(name: "Poppins-Bold", size: 16.0)!, range: NSRange(location: 57, length: 12))
        return NSAttributedString(attributedString: attributedString)
    }
}
