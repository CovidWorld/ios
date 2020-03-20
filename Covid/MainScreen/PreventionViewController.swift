import UIKit

class PreventionViewController: UIViewController {

    let datasource = [
        ("prevention01", "Často si umývajte ruky mydlom a vodou, najmenej po dobu 20 sekúnd. Môžete použiť dezinfekčný prostriedok na ruky na báze alkoholu."),
        ("prevention02", "Zakrývajte si nos a ústa pri kašľaní a kýchaní jednorázovou papierovou vreckovkou a následne zahoďte."),
        ("prevention03", "Nedotýkajte sa očí, nosa a úst neumytými rukami."),
        ("prevention04", "Vyhýbajte sa blízkemu kontaktu s ľuďmi, ktorí javia príznak nádchy alebo chrípky."),
        ("prevention05", "Noste ochrannú masku v prípade, že sa u Vás alebo u osôb vo Vašej blízkosti prejavujú respiračné symptómy."),
        ("prevention06", "Pravidelne čistite a deyinfikujte povrchz a objekty s ktorými ste Vy a Vaše okolie v pravidelnom kontakte."),
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
