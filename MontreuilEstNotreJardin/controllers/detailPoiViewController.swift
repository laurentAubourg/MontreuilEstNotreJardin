//
//  infosViewController.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 28/01/2022.
//

import UIKit

class detailPoiViewController: UIViewController {
    
    @IBOutlet weak var infosLab: UILabel!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var wayBtn: UIButton!
    weak var delegate:MainViewController?
    var poi:Poi?
    private let reuseIdentifier = "cell"
    
    //MARK: - life cycle
    
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
        if (poi?.favorit == true){
            favoriteBtn.setImage(UIImage(named: "favoriteOn"), for: .normal)
        }else{
            favoriteBtn.setImage(UIImage(named: "favoriteOff"), for: .normal)
        }
    }
    
    //MARK: the favorit button is tapped
    
    @IBAction func favoritBtnTapped(_ sender: Any) {
        delegate!.addPoiToFavorit()
        if (poi?.favorit == true){
            
            favoriteBtn.setImage(UIImage(named: "favoriteOn"), for: .normal)
        }else{
            favoriteBtn.setImage(UIImage(named: "favoriteOff"), for: .normal)
        }
        
    }
    
    //MARK: the iterary button is tapped
    
    @IBAction func wayBtnTapped(_ sender: Any) {
        delegate!.tracePath()
        dismiss(animated: true, completion: nil)
    }
}




