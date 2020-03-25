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
//  SpreadViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 22/03/2020.
//

import UIKit

struct RegionsData: Codable {
    let features: [RegionAttributes]
}

struct RegionAttributes: Codable {
    let attributes: RegionInfo
}

class RegionInfo: NSObject, Codable {
    let region: String
    let cases: Int?
    let id: Int
    var location: LocationJSON?
    
    enum CodingKeys: String, CodingKey {
        case region = "NM3"
        case cases = "POTVRDENI"
        case id = "IDN3"
        case location = "location"
    }
}

struct LocationJSON: Codable {
    let lat: Double
    let lon: Double
}

class SpreadViewController: UIViewController {
    @IBOutlet var mapContainerView: UIView!
    @IBOutlet var listContainerView: UIView!
    
    private var mapViewController: SpreadMapViewController?
    private var listViewController: SpreadListTableViewController?
    
    private var data = [RegionInfo]()
    
    override func viewDidLoad() {
    super.viewDidLoad()

        mapViewController = children.first(where: { $0 is SpreadMapViewController }) as? SpreadMapViewController
        listViewController = children.first(where: { $0 is SpreadListTableViewController }) as? SpreadListTableViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            if sender.selectedSegmentIndex == 0 {
                self.mapContainerView.alpha = 1
                self.listContainerView.alpha = 0
            } else {
                self.mapContainerView.alpha = 0
                self.listContainerView.alpha = 1
            }
        }
    }

    private func loadData() {
        var urlString = "https://portal.minv.sk/gis/rest/services/PROD/ESISPZ_GIS_PORTAL_CovidPublic/MapServer/4/query?where=POTVRDENI%20%3E%200&f=json&outFields=IDN3%2C%20NM3%2C%20IDN2%2C%20NM2%2C%20POTVRDENI%2C%20VYLIECENI%2C%20MRTVI%2C%20AKTIVNI%2C%20CAKAJUCI%2C%20OTESTOVANI_NEGATIVNI%2C%20DATUM_PLATNOST&returnGeometry=false&orderByFields=POTVRDENI%20DESC"
        
        urlString = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?["mapStatsUrl"].stringValue ?? urlString
        
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                do {
                    if let data = data {
                        let result = try JSONDecoder().decode(RegionsData.self, from: data)
                        let decodedData = result.features.map { $0.attributes }.sorted(by: { $00.region < $1.region })
                        
                        if let path = Bundle.main.path(forResource: "okresy", ofType: "json") {
                            let regionsData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                            let regions = try JSONDecoder().decode([RegionInfo].self, from: regionsData)
                            decodedData.forEach { region in
                                region.location = regions.first(where: { $0.id == region.id })?.location
                            }
                            
                        }
                        
                        self?.data = decodedData
                        
                        DispatchQueue.main.async {
                            self?.listViewController?.data = decodedData
                            self?.mapViewController?.data = decodedData
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
