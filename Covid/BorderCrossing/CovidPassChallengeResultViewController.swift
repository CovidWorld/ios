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
//  CovidPassChallengeResultViewController.swift
//  Covid
//
//  Created by Boris Bielik on 17/05/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit
import SwiftOTP
import UILabel_Copyable
import SwiftyUserDefaults

extension CovidPassChallengeResultViewController: HasStoryBoardIdentifier {
    static let storyboardIdentifier = "CovidPassChallengeResultViewController"
}

final class CovidPassChallengeResultViewController: ViewController {

    var code: Int64?
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private var challengeLabel: UILabel!

    override func loadView() {
        super.loadView()

        challengeLabel.isCopyingEnabled = true
        nextButton.layer.cornerRadius = 20
        nextButton.layer.masksToBounds = true

        if let code = code, let qPass = Defaults.QPass {
            let data = qPass.data(using: .utf8)!
            let hotp = HOTP(secret: data, digits: 6, algorithm: .sha256)!
            let counter = UInt64(code)
            let challenge = hotp.generate(counter: counter)
            challengeLabel.text = challenge
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = nil
    }

    @IBAction private func onNext(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

}
