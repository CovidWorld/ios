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
import MapKit

struct RegionsData: Codable {
    let features: [RegionAttributes]
}

struct RegionAttributes: Codable {
    let attributes: RegionInfo
}

final class RegionInfo: NSObject, Codable {
    let region: String
    let county: String
    let cases: Int?
    let id: Int
    var location: LocationJSON?

    enum CodingKeys: String, CodingKey {
        case region = "NM3"
        case county = "NM2"
        case cases = "POTVRDENI"
        case id = "IDN3"
        case location = "location"
    }
}

struct LocationJSON: Codable {
    let lat: Double
    let lon: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

protocol SwitchableViewController {
    func didPresentViewController()
}

enum ViewType: Int {
    case map
    case list
}

final class SpreadViewController: UIViewController {

    @IBOutlet private var mapContainerView: UIView!
    @IBOutlet private var listContainerView: UIView!

    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    private var mapViewController: SpreadMapViewController?
    private var listViewController: SpreadListTableViewController?

    private var data = [RegionInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapViewController = children.first { $0 is SpreadMapViewController } as? SpreadMapViewController
        listViewController = children.first { $0 is SpreadListTableViewController } as? SpreadListTableViewController
        listViewController?.onRegionSelect = { [weak self] regionInfo in
            self?.selectRegion(with: regionInfo)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    // MARK: Segmented control

    @IBAction private func segmentedControlDidChange(_ sender: UISegmentedControl) {
        guard let viewType = ViewType(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        switchToViewType(viewType, animated: true)
    }

    // MARK: Select Region

    private func selectRegion(with regionInfo: RegionInfo) {
        switchToViewType(.map, animated: true) { [weak self] in
            self?.mapViewController?.selectAnnotation(with: regionInfo)
        }
    }

    // MARK: Switch views

    private func switchToViewType(_ viewType: ViewType,
                                  animated: Bool,
                                  completion: (() -> Void)? = nil) {
        func switchToViewType(_ viewType: ViewType) {
            segmentedControl.selectedSegmentIndex = viewType.rawValue
            mapContainerView.alpha = viewType == ViewType.map ? 1 : 0
            listContainerView.alpha = viewType == ViewType.list ? 1 : 0
        }

        let switchableViewController: SwitchableViewController = viewType == .map ? mapViewController! : listViewController!
        if animated {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            switchToViewType(viewType)
                }, completion: { _ in
                    completion?()
                    switchableViewController.didPresentViewController()
            })
        } else {
            switchToViewType(viewType)
            completion?()
            switchableViewController.didPresentViewController()
        }
    }

    // MARK: Load data

    private func loadData() {
        let urlString = Firebase.remoteStringValue(for: .mapStatsUrl)

        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
                do {
                    if let data = data {
                        let result = try JSONDecoder().decode(RegionsData.self, from: data)
                        let decodedData = result.features
                            .map { $0.attributes }
                            .sorted { $0.region < $1.region }

                        if let path = Bundle.main.path(forResource: "okresy", ofType: "json") {
                            let regionsData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                            let regions = try JSONDecoder().decode([RegionInfo].self, from: regionsData)
                            decodedData.forEach { region in
                                region.location = regions.first { $0.id == region.id }?.location
                            }

                        }

                        self?.data = decodedData

                        DispatchQueue.main.async {
                            self?.listViewController?.data = decodedData
                            self?.mapViewController?.data = decodedData
                        }
                    }
                } catch let error {
                    print(error)
                }
            }
            task.resume()
        }
    }
}
