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

import UIKit
import MapKit
import CoreLocation

protocol MapSearchProtocol: AnyObject {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var chooseButton: UIButton!
    
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    private var lastPlacemark: CLPlacemark? = nil
    
    var selectedPin: MKPlacemark? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            performSegue(withIdentifier: "search", sender: self)
        }
        
        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let confirmationViewController = segue.destination as? AddressConfirmationViewController {
            var streetText = ""
            var cityText = ""
            
            if let placemark = lastPlacemark {
                if let street = placemark.thoroughfare {
                    streetText.append(street)
                }
                if let subThoroughfare = placemark.subThoroughfare {
                    if streetText.count > 0 {
                        streetText.append(" ")
                    }
                    streetText.append(subThoroughfare)
                }
                
                if let postalCode = placemark.postalCode {
                    cityText.append(postalCode)
                }
                if let city = placemark.locality {
                    if cityText.count > 0 {
                        cityText.append(" ")
                    }
                    cityText.append(city)
                }
            } else {
                streetText = " - "
                cityText = " - "
            }
            
            confirmationViewController.streetText = streetText
            confirmationViewController.cityText = cityText
            confirmationViewController.location = lastPlacemark?.location?.coordinate
        } else if let searchMapViewController = segue.destination as? SearchMapViewController {
            searchMapViewController.mapView = mapView
            searchMapViewController.mapSearchDelegate = self
        }
    }
}

extension MapViewController {
    
    private func setupUI() {
        chooseButton.setImage(UIImage(named: "pin"), for: .normal)
        chooseButton.imageView?.contentMode = .scaleAspectFit
        chooseButton.setTitle("Načítavam pozíciu...", for: .disabled)
    }
    
    private func setButtonTitle(with text: String?) {
        guard let text = text else { return }
        
        let substring1 = "Vybrať túto polohu\n"
        let substring2 = text
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        
        let font1: UIFont = UIFont(name: "Poppins-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .heavy)
        let attributes1 = [NSMutableAttributedString.Key.font: font1,
                           .foregroundColor: UIColor.white,
                           .paragraphStyle: paragraph]
        let attrString1 = NSMutableAttributedString(string: substring1, attributes: attributes1)

       

        let font2: UIFont = UIFont(name: "Inter-Light", size: 14) ??  UIFont.systemFont(ofSize: 14, weight: .medium)
        let attributes2 = [NSMutableAttributedString.Key.font: font2,
                           .foregroundColor: UIColor.white,
                           .paragraphStyle: paragraph]
        let attrString2 = NSMutableAttributedString(string: substring2, attributes: attributes2)
        attrString1.append(attrString2)
        
        chooseButton?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        chooseButton?.setAttributedTitle(attrString1, for: [])
    }
    
    private func address(from placemark: CLPlacemark?) -> String {
        var address: String = ""
        
        if let placemark = placemark {
            if let street = placemark.thoroughfare {
                address.append(street)
            }
            if let subThoroughfare = placemark.subThoroughfare {
                if address.count > 0 {
                    address.append(" ")
                }
                address.append(subThoroughfare)
            }
            if let postalCode = placemark.postalCode {
                if address.count > 0 {
                    address.append(", ")
                }
                address.append(postalCode)
            }
            if let city = placemark.locality {
                if address.count > 0 {
                    address.append(" ")
                }
                address.append(city)
            }
        } else {
            address = " - "
        }
        
        return address
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            self.lastPlacemark = placemarks?.first
            let addressString = self.address(from: placemarks?.first)
            self.setButtonTitle(with: addressString)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last, selectedPin == nil {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            performSegue(withIdentifier: "search", sender: self)
        }
    }
}

extension MapViewController: MapSearchProtocol {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
