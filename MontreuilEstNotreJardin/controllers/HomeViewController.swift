//
//  HomeViewController.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 17/02/2022.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let dataSetService:DataSetService = .init()
    private var resources:[Resource]? = nil
    private let reuseIdentifier = "cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "HomeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        loadResources()
    }
    private func loadResources(){
        dataSetService.getResources(callback:{ result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success( let data):
                    self!.resources = data
                    self?.tableView.reloadData()
                    break
                case .failure(let error):
                    self?.presentAlert(title: "Error", message:"The resources download failed.:\(error)")
                }}
        })
    }
    //MARK: - PopUp Segue
   
    override   func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
       
        if segue.identifier == "viewPresentation"
        {
            let vc =  segue.destination as! WebViewController
            vc.type = "presentation"
        }
    }
 
}
//MARK: - -------- UITableViewDelegate Extension ---------------

extension HomeViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        guard  let item = self.resources else {return}
     let resource = item[indexPath.row]
        let segue = resource.segue
        let type = resource.type
        performSegue(withIdentifier: segue, sender: indexPath.row)
        
    }
    
}

//MARK: -  -------- TableViewDataSource Extension ---------------

extension  HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let resource = resources else {return 0}
        return resource.count
        
    }
    // MARK: - Filling the tableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)! as! HomeTableViewCell
        guard  let item = self.resources else {return cell}
     let resource = item[indexPath.row]
        cell.iconImageView.image = UIImage(named: resource.icon)
        cell.comment.text = resource.comment
        cell.titleLab.text = resource.title
     
            
        
        
        return cell
    }
}
