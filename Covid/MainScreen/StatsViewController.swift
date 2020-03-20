//
//  StatsViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 19/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    
    @IBOutlet var positiveCasesLabel: UILabel!
    @IBOutlet var healedCasesLabel: UILabel!
    @IBOutlet var deathsLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        let urlString = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?["statsUrl"].stringValue ?? "https://corona-stats-sk.herokuapp.com/world"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let data = data, let result = try? decoder.decode(StatsResponseData.self, from: data) {
                    DispatchQueue.main.async {
                        self?.positiveCasesLabel.text = String(Int(result.totalCases))
                        self?.healedCasesLabel.text = String(Int(result.totalRecovered))
                        self?.deathsLabel.text = String(Int(result.totalDeaths))
                    }
                }
            }
            task.resume()
        }
    }
}
