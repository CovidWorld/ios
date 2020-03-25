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

class StatsViewController: UIViewController {
    
    @IBOutlet var positiveCasesLabel: UILabel!
    @IBOutlet var healedCasesLabel: UILabel!
    @IBOutlet var deathsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        reloadData()
    }
    
    @objc
    private func reloadData() {
        let urlString = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?["statsUrl"].stringValue ?? "https://corona-stats-sk.herokuapp.com/combined"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    if let data = data {
                        let result = try decoder.decode(StatsResponseData.self, from: data)
                        DispatchQueue.main.async {
                            self?.positiveCasesLabel.text = String(Int(result.totalCases))
                            self?.healedCasesLabel.text = String(Int(result.totalRecovered))
                            self?.deathsLabel.text = String(Int(result.totalDeaths))
                        }
                    }
                }catch let error {
                    print(error)
                }
            }
            task.resume()
        }
    }
}
