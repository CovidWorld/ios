//
//  NSString+Localised.swift
//  Covid
//
//  Created by Boris Bielik on 26/05/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit

func LocalizedString(forKey key: String) -> String {
    NSLocalizedString(key,
                      tableName: "Localizable",
                      bundle: .main,
                      value: "",
                      comment: "")
}

protocol XIBLocalizable {
    var localizedKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var localizedKey: String? {
        get { nil }
        set(key) {
            guard let key = key else {
                text = nil
                return
            }
            text = LocalizedString(forKey: key)
        }
    }
}
extension UIButton: XIBLocalizable {
    @IBInspectable var localizedKey: String? {
        get { nil }
        set(key) {
            guard let key = key else {
                setTitle(nil, for: .normal)
                return
            }
            let title = LocalizedString(forKey: key)
            setTitle(title, for: .normal)
        }
   }
}

extension UINavigationItem: XIBLocalizable {
    @IBInspectable var localizedKey: String? {
        get { nil }
        set(key) {
            guard let key = key else {
                return
            }
            title = LocalizedString(forKey: key)
        }
    }
}

extension UIBarItem: XIBLocalizable {
    @IBInspectable var localizedKey: String? {
        get { nil }
        set(key) {
            guard let key = key else {
                return
            }
            title = LocalizedString(forKey: key)
        }
    }
}
