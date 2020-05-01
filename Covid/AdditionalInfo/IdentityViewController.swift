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
//  IdentityViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 23/03/2020.
//

import UIKit
import UILabel_Copyable
import SwiftyUserDefaults

final class IdentityViewController: ViewController {
    @IBOutlet private var idLabel: UILabel!
    @IBOutlet private var uploadDataView: UIView!
    @IBOutlet private var cooperationLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let covidPass = Defaults.covidPass {
            idLabel.text = covidPass
        } else if let profileId = Defaults.profileId {
            let hashids = Hashids(salt: "COVID-19 super-secure and unguessable hashids salt", minHashLength: 6, alphabet: "ABCDEFGHJKLMNPQRSTUVXYZ23456789")
            idLabel.text = hashids.encode(profileId)?.uppercased()
        }

        uploadDataView.isHidden = Firebase.remoteBoolValue(for: .reporting)

        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.isHidden = false
    }

    override func loadView() {
        super.loadView()
        uploadDataView.layer.cornerRadius = 20
        uploadDataView.layer.masksToBounds = true

        idLabel.isCopyingEnabled = true

        let text = "Tento projekt vznikol\nako spojenie dobrovoľnej iniciatívy\nZostanZdravy a Sygic"
        let attribbutes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Poppins-Regular", size: 15.0)!, .foregroundColor: UIColor.darkGray]
        let attributedString = NSMutableAttributedString(string: text, attributes: attribbutes)
        let zostanRange = (attributedString.string as NSString).range(of: "ZostanZdravy")
        let sygicRange = (attributedString.string as NSString).range(of: "Sygic")
        attributedString.setAttributes([.font: UIFont(name: "Poppins-Bold", size: 15.0)!], range: zostanRange)
        attributedString.setAttributes([.font: UIFont(name: "Poppins-Bold", size: 15.0)!], range: sygicRange)
        cooperationLabel.attributedText = attributedString
    }

    @IBAction private func uploadDataTapped(_ sender: UIButton) {
        LocationReporter.shared.sendConnections(forceUpload: true)
    }
}
