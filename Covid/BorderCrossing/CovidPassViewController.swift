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
//  CovidPassViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 13/05/2020.
//

import UIKit
import UILabel_Copyable
import SwiftyUserDefaults

extension CovidPassViewController: HasStoryBoardIdentifier {
    static let storyboardIdentifier = "CovidPassViewController"
}

final class CovidPassViewController: ViewController {
    @IBOutlet private var idLabel: UILabel!
    @IBOutlet private var qrCodeImageView: UIImageView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let covidPass = Defaults.covidPass

        idLabel.text = covidPass
        qrCodeImageView.image = covidPass?.barCodeImage

        if Defaults.quarantineStart != nil {
            navigationItem.rightBarButtonItem = nil
        }

        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: LocalizedString(forKey: "button.back"), style: .plain, target: self, action: #selector(CovidPassViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    @objc
    private func back(sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction private func onNext(_ sender: Any) {
        let viewController = PasscodeLockViewController()
        navigationController?.pushViewController(viewController, animated: true)
        viewController.successCallback = { [weak self] passcodeString in
            if let passCode = Int64(passcodeString) {
                self?.showResult(for: passCode)
            }
        }
    }

    private func showResult(for passCode: Int64) {
        guard let resultViewController = UIStoryboard.controller(ofType: CovidPassChallengeResultViewController.self) else {
            return
        }
        resultViewController.code = passCode

        navigationController?.pushViewController(resultViewController, animated: true)
    }

    override func loadView() {
        super.loadView()

        idLabel.isCopyingEnabled = true
    }
}
