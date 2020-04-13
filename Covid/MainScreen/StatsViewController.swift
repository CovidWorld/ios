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
//  StatsViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 19/03/2020.
//

import UIKit

final class StatsViewController: UIViewController {

    @IBOutlet private var positiveView: UIView!
    @IBOutlet private var healedView: UIView!
    @IBOutlet private var positiveCasesLabel: UILabel!
    @IBOutlet private var healedCasesLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: UIApplication.willEnterForegroundNotification, object: nil)
        reloadData()
    }

    override func loadView() {
        super.loadView()
        let borderColor = UIColor(red: 217 / 255.0, green: 221 / 255.0, blue: 238 / 255.0, alpha: 1).cgColor

        positiveView.layer.cornerRadius = 10
        positiveView.layer.masksToBounds = true
        positiveView.layer.borderWidth = 0.5
        positiveView.layer.borderColor = borderColor
        healedView.layer.cornerRadius = 10
        healedView.layer.masksToBounds = true
        healedView.layer.borderWidth = 0.5
        healedView.layer.borderColor = borderColor
    }

    @objc
    private func reloadData() {
        let urlString = Firebase.remoteStringValue(for: .statsUrl)
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            do {
                guard let data = data else { return }

                let result = try JSONDecoder().decode(StatsResponseData.self, from: data)
                DispatchQueue.main.async {
                    self?.positiveCasesLabel.text = String(result.totalCases)
                    self?.healedCasesLabel.text = String(result.totalRecovered)
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
}
