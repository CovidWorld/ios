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

class PreventionViewController: UIViewController {

    let datasource = [
        ("prevention01", "Často si umývajte ruky mydlom a vodou, najmenej po dobu 20 sekúnd. Môžete použiť dezinfekčný prostriedok na ruky na báze alkoholu."),
        ("prevention02", "Zakrývajte si nos a ústa pri kašľaní a kýchaní jednorázovou papierovou vreckovkou a následne zahoďte."),
        ("prevention03", "Nedotýkajte sa očí, nosa a úst neumytými rukami."),
        ("prevention04", "Vyhýbajte sa blízkemu kontaktu s ľuďmi, ktorí javia príznak nádchy alebo chrípky."),
        ("prevention05", "Noste ochrannú masku v prípade, že sa u Vás alebo u osôb vo Vašej blízkosti prejavujú respiračné symptómy."),
        ("prevention06", "Pravidelne čistite a dezinfikujte povrchy a objekty s ktorými ste Vy a Vaše okolie v pravidelnom kontakte."),
        ("prevention07", "Ak ste chorý, liečte sa doma.") 
    ]
}

extension PreventionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { datasource.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PreventionTableViewCell.self), for: indexPath) as? PreventionTableViewCell else { return UITableViewCell() }
        
        cell.iconImageView.image = UIImage(named: datasource[indexPath.row].0)
        cell.titleLabel.text = datasource[indexPath.row].1
        cell.selectionStyle = .none
        
        return cell
    }
}
