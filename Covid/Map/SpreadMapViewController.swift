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
//  SpreadMapViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 22/03/2020.
//

import UIKit
import MapKit

extension RegionInfo: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        location?.coordinate ?? CLLocationCoordinate2D()
    }

    var title: String? {
        region
    }

    var subtitle: String? {
        LocalizedString(forKey: "stats.numberOfCases") + "\(cases ?? 0)"
    }
}

final class SpreadMapViewController: ViewController {

    @IBOutlet private var mapView: MKMapView!

    let regionIdenfitier = "region"

    var data = [RegionInfo]() {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(data)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsCompass = false
        mapView.isRotateEnabled = false
        if #available(iOS 11.0, *) {
            mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: regionIdenfitier)
        }
    }

    func selectAnnotation(with regionInfo: RegionInfo) {
        let annotation = mapView.annotations
                                .compactMap { $0 as? RegionInfo }
                                .first { $0.coordinate == regionInfo.coordinate }
        guard let regionAnnotation = annotation else { return }

        mapView?.setCenter(regionAnnotation.coordinate, animated: true)
        let view = mapView.view(for: regionAnnotation)
        if #available(iOS 11.0, *) {
            view?.prepareForDisplay()
        }
        mapView.deselectAnnotation(regionAnnotation, animated: false)
        mapView.selectAnnotation(regionAnnotation, animated: true)
    }
}

extension SpreadMapViewController: SwitchableViewController {
    func didPresentViewController() {}
}

extension SpreadMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      guard let annotation = annotation as? RegionInfo else { return nil }
        if #available(iOS 11.0, *) {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: regionIdenfitier, for: annotation)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 15)
            view.rightCalloutAccessoryView = UIView()
            return view
        } else {
            return MKAnnotationView(annotation: annotation, reuseIdentifier: regionIdenfitier)
        }
    }
}
