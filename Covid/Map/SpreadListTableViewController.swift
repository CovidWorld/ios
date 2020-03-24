//
//  SpreadListTableViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 22/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit

class StatsHeaderView: UITableViewHeaderFooterView {
    let region = UILabel()
    let cases = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(region)
        contentView.addSubview(cases)
        region.translatesAutoresizingMaskIntoConstraints = false
        cases.translatesAutoresizingMaskIntoConstraints = false
        region.font = UIFont(name: "Poppins-Medium", size: 17)
        cases.font = UIFont(name: "Poppins-Medium", size: 17)

        NSLayoutConstraint.activate([
            region.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cases.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            region.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: cases.trailingAnchor, constant: 16)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpreadListTableViewController: UITableViewController {
    var data = [RegionInfo]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath)
        
        cell.textLabel?.text = data[indexPath.row].region
        cell.detailTextLabel?.text = String((data[indexPath.row].cases ?? 0))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: StatsHeaderView
        if let dequeuedHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? StatsHeaderView {
            header = dequeuedHeader
        } else {
            header = StatsHeaderView(reuseIdentifier: "header")
        }
        header.region.text = "Okres"
        header.cases.text = "Počet prípadov"
        return header
    }
}

