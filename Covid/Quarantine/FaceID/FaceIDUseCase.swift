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
//  FaceIDUseCase.swift
//  Covid
//
//  Created by Boris Bielik on 04/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit

enum FaceIDUseCase {
    case registerFace
    case verifyFace
    case borderCrossing

    var title: String {
        switch self {
        case .registerFace:
            return "Odfotiť tvár"
        case .verifyFace,
             .borderCrossing:
            return "Identifikujte sa tvárou"
        }
    }

    var verifyTitle: String {
        "Overenie tváre"
    }

    func completionTitle(didSuccess: Bool) -> String {
        didSuccess ? "Ďakujeme" : "Ľutujeme"
    }

    func completionDescription(didSuccess: Bool = true) -> String {
        switch self {
        case .verifyFace where didSuccess:
            return """
            Dodržiavajte naďalej dôsledne domácu
            izoláciu. Zabránite tak šíreniu vírusu
            COVID-19.
            """
        case .verifyFace where didSuccess == false:
            return """
            Nepodarilo sa dokončiť proces overenia prostredníctvom biometrie. Ak si želáte, môžete neskôr proces zopakovať z hlavného menu.
            """
        case .borderCrossing where didSuccess == true:
            return ""
        case .borderCrossing where didSuccess == false:
            return """
            Nepodarilo sa dokončiť proces overenia prostredníctvom biometrie.
            """
        default:
            return """
            Dodržiavajte dôsledne domácu izoláciu.
            Zabránite tak šíreniu vírusu COVID-19.
            """
        }
    }

    var actionButtonColor: UIColor {
        switch self {
        case .registerFace:
            return UIColor(red: 80.0 / 255.0, green: 88.0 / 255.0, blue: 249.0 / 255.0, alpha: 1.0)
        case .verifyFace,
             .borderCrossing:
            return UIColor(red: 41.0 / 255.0, green: 192.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0)
        }
    }

    func completionIcon(didSuccess: Bool = true) -> UIImage {
        guard didSuccess else { return #imageLiteral(resourceName: "ic_check-red") }

        switch self {
        case .registerFace:
            return #imageLiteral(resourceName: "ic_check-green")
        case.verifyFace,
            .borderCrossing:
            return #imageLiteral(resourceName: "ic_check-grey")
        }
    }
}
