//
//  WeatherViewController.swift
//  Montreuil ....
//
//  Created by laurent aubourg on 25/08/2021.
//

import UIKit
import MapKit
import CoreLocation


protocol MapkitDelegate{
    
}
final class MainViewController: UIViewController{
    
    
    
    // MARK: - @IBOUTLETS
    
    @IBOutlet weak var mapSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuTrailingConstraint           : NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    
    private let dataSetService:DataSetService = .init()
    var coreDataManager: CoreDataManager?
    private var currentCategoryRank = 0
    private let reuseIdentifier = "cell"
    private var menuOut = false
    
    //MARK: -Mapkit extension properties
    
    let locationBase = CLLocation(latitude:48.863812, longitude: 2.448451)
    var locationManager = CLLocationManager.init()
    var removeAnnotatioOnTap = true
    var currentPoi:Poi?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView
        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        //coreData
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        coreDataManager = CoreDataManager(coreDataStack:appdelegate.coreDataStack)
        //menu
        closeMenu()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeMenu))
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeMenu), name: UIDevice.orientationDidChangeNotification, object: nil)
        mapView.addGestureRecognizer(tap)
        //mapKit
        mapKitInit()
     
        
    }
  
    //MARK: - ------------- METHODS ------------------------------
    
    //mARK: - Load Category if it is not already done
    
    override func viewDidAppear(_ animated: Bool)        {
        if coreDataManager?.categories.count == 0 {
            loadCategories()
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    //MARK: Set selected attribute true in the Category entity
   
   func categoryIsSelected(_ rank:Int){
       coreDataManager?.selectCategory((coreDataManager?.categories[rank])!)
   }
   
   //MARK: set selected attribute false in the Category entity
   
   func categoryIsUnselected(_ rank:Int){
       coreDataManager?.unselectCategory((coreDataManager?.categories[rank])!)
   }
    //MARK: - ------------------ DATASET METHOD'S ---------------------
    
    //MARK: Load  facets JSON and maj coreData Category entity
    
    private func loadCategories(){
        dataSetService.getFacets(callback:{ result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success( let data):
                    //   self?.activityIndicator.isHidden = false
                    for facet in data.facets{
                        
                        if facet.name == "categorie" {
                            let categories = facet.facets
                            for categorie in categories{
                                self!.coreDataManager?.addCategorie(name: categorie.name, nbRecords: Int32(categorie.nbRecords),state:categorie.state)
                            }
                          //  if (withPoi == true){
                                self!.loadPoi()
                         //   }
                        }
                        continue
                    }
                    
                    break
                case .failure(let error):
                    self?.presentAlert(title: "Error", message:"The facets download failed.:\(error)")
                }}
        })
    }
    // MARK: Load  Poi JSON and maj coreData Poi entity for all categories
    
    func loadPoi(){
        
        let categories = coreDataManager?.categories as [Category]?
        guard categories != nil else{return}
        let categorie = coreDataManager?.categories[currentCategoryRank]
        guard categorie != nil else{return}
        guard categorie!.name != nil else{return}
        let nbRecords:Int32 = categorie!.nbRecords
        let nameCategory = categorie!.name
        dataSetService.getPoi(for: nameCategory! , nbRecords:Int(nbRecords),  callback:{ [weak self] result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success( let data):
                    self?.coreDataManager?.addPoi(categorie: categorie!, pois: data.records)
                    break
                case .failure(let error):
                    self?.presentAlert(title: "Error", message:"The Poi records download failed.:\(error)")
                }
            }
            if categories!.count >  self!.currentCategoryRank+1{
                
                self?.currentCategoryRank += 1
                self?.loadPoi()
            }else{
                DispatchQueue.main.async {
                    //  activityIndicator.stopAnimating()
                    self?.presentAlert(title: "Info", message:"DataIs Loaded.!")
                    
                }
                
                
            }
        })
        
        return
    }
    
    
    //MARK: clean Category Entities and reLoad  facets JSON and maj coreData Category entity
    
    private func reloadCategories(withPoi:Bool = false){
        //   activityIndicator.stopAnimating()
        coreDataManager?.deleteAllcategories()
      //  coreDataManager?.deleteAllpois()
        loadCategories()
    }
   
  
  
    
  
}
//MARK: - ----------------- MENU UITableView DELEGATE EXTENSION

//MARK: - activate or deactivate the checkBox button of the cell

extension MainViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let category = coreDataManager?.categories[indexPath.row] else{return}
      if(category.selected == true){
            coreDataManager?.unselectCategory(category)
        }else{
            coreDataManager?.selectCategory(category)
        }
        tableView.reloadData()
        
    }
    
}

//MARK: -  -------- TableViewDataSource Extension ---------------

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (coreDataManager?.categories.count) ?? 0
    }
    
    // MARK: - Filling the tableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = coreDataManager?.categories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! MenuTableViewCell
        cell.delegate = self
        
        cell.titleLab.text = item!.name
        cell.checkBoxBtn.tag = indexPath.row
        cell.checkBoxBtn.isSelected = ((item?.selected) == true)
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
}

// MARK: - ---------  MenuDelegate extension -----------------

extension  MainViewController:MenuDelegate{
    
    //MARK: button Menu is tapped
    
    @IBAction func menuIsTapped(_ sender: Any) {
        removeAnnotatioOnTap = true
        if menuOut == false{
            closeMenu()
        }else{
            
            openMenu()
        }
    }
    // MARK: - Add a place to the list of favorites
    
    func addPoiToFavorit(){
        if currentPoi?.favorit == true{
            coreDataManager?.removePoiToFavorit(poi:currentPoi)
            return
        }
        coreDataManager?.addPoiToFavorit(poi:currentPoi)
    }
  
    
    //MARK: - hide menu
    
    @objc func closeMenu(){
      
       menuLeadingConstraint.constant = -(view.frame.width*2)
        menuTrailingConstraint.constant = view.frame.width*2
        menuOut = true
        if removeAnnotatioOnTap == true
         {
        addSelectedPoiAnnotation()
       }
    }
    
    //MARK: - display menu
    
    func openMenu(){
        
        
        menuLeadingConstraint.constant = 5
        menuTrailingConstraint.constant = view.frame.width/2
        
        menuOut = false
    }
  
}
