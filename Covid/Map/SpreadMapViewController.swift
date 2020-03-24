//
//  SpreadMapViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 22/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
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
        return region
    }
    
    var subtitle: String? {
        return "Počet prípadov: \(cases ?? 0)" 
    }
}

class SpreadMapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    var data = [RegionInfo]() {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(data)
        }
    }
}
