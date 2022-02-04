//
//  FavoriteViewController.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 03/02/2022.
//

import UIKit

class FavoriteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var coreDataManager: CoreDataManager?
    private let reuseIdentifier = "cell"
    private var favoritePois:[Poi] = []
    var delegate:MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FavoriteTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        coreDataManager = CoreDataManager(coreDataStack:appdelegate.coreDataStack)
        tableView.delegate = self
        tableView.dataSource = self
        guard let favorites = coreDataManager?.getFavoritesPoi() else{
            return}
        favoritePois = favorites
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool)        {
       
    }
}

//MARK: - -------- UITableViewDelegate Extension ---------------

extension FavoriteViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let poi = favoritePois[indexPath.row]
        delegate?.zoomPoi(poi:poi)
        dismiss(animated:false , completion: nil)
    }

}

//MARK: -  -------- TableViewDataSource Extension ---------------

extension  FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return favoritePois.count
       
    }
    
    // MARK: - Filling the tableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let item = favoritePois[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as!FavoriteTableViewCell
      
        cell.titleLab.text = item.name
        cell.iconImageView.image = UIImage(named:item.category?.icon ?? "")

      
        return cell
    }
    
}
