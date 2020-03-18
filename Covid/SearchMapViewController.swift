import UIKit
import MapKit

class SearchMapViewController: UIViewController {
    let cellID = "SearchCell"
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    weak var mapSearchDelegate: MapSearchProtocol? = nil

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dragIdicatorView: UIView!
    @IBOutlet weak var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {
            searchBar.searchTextField.font = UIFont(name: "Inter-UI-Regular", size: 16) ??  UIFont.systemFont(ofSize: 16, weight: .regular)
            searchBar.searchTextField.textColor = .black
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        self.searchBar.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13, *) {
            closeButton.isHidden = true
            dragIdicatorView.isHidden = false
        } else {
            closeButton.isHidden = false
            dragIdicatorView.isHidden = true
        }
    }

    @IBAction func dismissDidTap(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension SearchMapViewController {

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

extension SearchMapViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let mapView = mapView else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let response = response else { return }
            self?.matchingItems = response.mapItems
            self?.tableView.reloadData()
        }
    }
}

extension SearchMapViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if matchingItems.count > 0 {
            tableView.backgroundView = UIView()
            return 1
        }
        tableView.backgroundView = emptyViewLabel()
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { matchingItems.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = address(from: selectedItem)
        
        return cell
    }
}

extension SearchMapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        mapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true)
    }
}

extension SearchMapViewController {
    func emptyViewLabel() -> UIView {
        let rect = CGRect(origin: CGPoint(x: 0,y :0),
                          size: CGSize(width: view.bounds.size.width,
                                       height: view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = "Vyhľadajte prosím miesto v ktorom sa budete zdržiavať\n\n\n\n\n\n"
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Inter-Light", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .light)
        messageLabel.sizeToFit()

        return messageLabel
    }
}
