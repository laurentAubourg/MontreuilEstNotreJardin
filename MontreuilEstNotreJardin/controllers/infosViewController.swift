//
//  infosViewController.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 28/01/2022.
//

import UIKit

class infosViewController: UIViewController {

    @IBOutlet weak var infosLab: UILabel!
    @IBOutlet weak var nameLab: UILabel!
    
    var delegate:MainViewController?
    var poi:Poi?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        guard poi != nil else {return}
        let title = poi!.name
        let address = " adresse: \(poi!.address ?? "NC.")"
        let email = " email: \(poi!.email ?? "NC.")"
        let telephon = " téléphone: \(poi!.telephon ?? "NC.")"
        let info = "\(address) \n \n\(email) \n\(telephon)!"
        nameLab.text = title
        infosLab.text = info
        // Do any additional setup after loading the view.
    }
    


    @IBAction func favoritBtnTapped(_ sender: Any) {
        delegate!.addPoiToFavorit()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
