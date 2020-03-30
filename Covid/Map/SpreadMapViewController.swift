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
        guard let latitude = location?.lat, let longitude = location?.lon else {
            return CLLocationCoordinate2D()
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var title: String? {
        region
    }

    var subtitle: String? {
        "Počet prípadov: \(cases ?? 0)"
    }
}

final class SpreadMapViewController: UIViewController {
    @IBOutlet private var mapView: MKMapView!

    var data = [RegionInfo]() {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(data)
        }
    }
}

extension SpreadMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      guard let annotation = annotation as? RegionInfo else { return nil }
      let identifier = "region"
        if #available(iOS 11.0, *) {
            var view: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: 0, y: 15)
                view.rightCalloutAccessoryView = UIView()
            }
            return view
        } else {
            return MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
    }
}
