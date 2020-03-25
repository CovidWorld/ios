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
//  AdditionalInfoViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 22/03/2020.
//

import UIKit

final class AdditionalInfoViewController: UIViewController {

    @IBOutlet private var protectView: UIView!
    @IBOutlet private var symptomsView: UIView!
    @IBOutlet private var howItWorksView: UIView!

    override func loadView() {
        super.loadView()

        protectView.layer.cornerRadius = 20
        protectView.layer.masksToBounds = true
        symptomsView.layer.cornerRadius = 20
        symptomsView.layer.masksToBounds = true
        howItWorksView.layer.cornerRadius = 20
        howItWorksView.layer.masksToBounds = true
    }
}
