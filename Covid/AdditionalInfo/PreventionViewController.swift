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

final class PreventionViewController: ViewController {

    @IBOutlet private weak var tableView: UITableView!

    let datasource = [
        ("prevention01", LocalizedString(forKey: "prevention.01")),
        ("prevention02", LocalizedString(forKey: "prevention.02")),
        ("prevention03", LocalizedString(forKey: "prevention.03")),
        ("prevention04", LocalizedString(forKey: "prevention.04")),
        ("prevention05", LocalizedString(forKey: "prevention.05")),
        ("prevention06", LocalizedString(forKey: "prevention.06")),
        ("prevention07", LocalizedString(forKey: "prevention.07"))
    ]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }
}

extension PreventionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { datasource.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: PreventionTableViewCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? PreventionTableViewCell else { return UITableViewCell() }

        cell.iconImageView.image = UIImage(named: datasource[indexPath.row].0)
        cell.titleLabel.text = datasource[indexPath.row].1
        cell.selectionStyle = .none

        return cell
    }
}
