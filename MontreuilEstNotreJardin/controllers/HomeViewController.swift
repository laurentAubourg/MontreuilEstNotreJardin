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
    private let cellSpacingHeight = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "HomeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        loadResources()
        view.addGradient(gradientColors: [UIColor.red.cgColor,UIColor.yellow.cgColor])
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
    
    //MARK: -Segue
    
    override   func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let resource = sender as! Resource
        
        if  segue.identifier == "segueViewSite"
        {
            let vc =  segue.destination as!  WebViewController
            vc.resource = resource
            
        }
    }
    
    @IBAction func reloadDataTapped(_ sender: Any) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appdelegate.reloadCategories()
    }
}

//MARK: - -------- UITableViewDelegate Extension ---------------

extension HomeViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard  let item = self.resources else {return}
        let resource = item[indexPath.section]
        let segue = resource.segue
        performSegue(withIdentifier: segue, sender: resource)
    }
    
}

//MARK: -  -------- TableViewDataSource Extension ---------------

extension  HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let resource = resources else {return 0}
        if  resource.count == 0 {
            
            self.tableView.setEmptyMessage("No recource in JSON file")
        } else {
            
            self.tableView.restore()
        }
        
        return resource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
    }
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(cellSpacingHeight)
    }
    
    // MARK: - Filling the tableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)! as! HomeTableViewCell
        guard  let item = self.resources else {return cell}
        let resource = item[indexPath.section]
        cell.iconImageView.image = UIImage(named: resource.icon)
        cell.comment.text = resource.comment
        cell.titleLab.text = resource.title
        return cell
    }
    
}
