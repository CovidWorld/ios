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
//  SpreadListTableViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 22/03/2020.
//

import UIKit

final class RegionCell: UITableViewCell {
    let regionLabel = UILabel()
    let casesLabel = UILabel()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        contentView.addSubview(regionLabel)
        contentView.addSubview(casesLabel)
        regionLabel.translatesAutoresizingMaskIntoConstraints = false
        casesLabel.translatesAutoresizingMaskIntoConstraints = false
        regionLabel.font = UIFont(name: "Poppins-Light", size: 15)
        casesLabel.font = UIFont(name: "Poppins-Bold", size: 15)
        regionLabel.textColor = textLabel?.textColor
        casesLabel.textColor = textLabel?.textColor

        NSLayoutConstraint.activate([
            casesLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.trailingAnchor.constraint(equalTo: casesLabel.trailingAnchor, constant: 34),
            regionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            regionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 34)
        ])
    }
}

final class SpreadListTableViewController: UITableViewController {
    var data = [RegionInfo]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath) as? RegionCell

        cell?.regionLabel.text = data[indexPath.row].region
        cell?.casesLabel.text = String((data[indexPath.row].cases ?? 0))

        return cell ?? UITableViewCell()
    }

}
