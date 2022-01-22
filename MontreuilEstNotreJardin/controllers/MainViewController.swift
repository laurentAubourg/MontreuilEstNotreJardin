//
//  WeatherViewController.swift
//  Montreuil ....
//
//  Created by laurent aubourg on 25/08/2021.
//

import UIKit
import MapKit
protocol MapkitDelegate{
    
}
final class MainViewController: UIViewController{
    
    
    
    // MARK: - @IBOUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var  menuTrailingConstraint           : NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    
    private let dataSetService:DataSetService = .init()
    private var coreDataManager: CoreDataManager?
    private var currentCategoryRank = 0
    private let reuseIdentifier = "cell"
    private var menuOut = false
    private let locationBase = CLLocation(latitude:48.863507755484214, longitude: 2.4486559017)
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        coreDataManager = CoreDataManager(coreDataStack:appdelegate.coreDataStack)
        
        
        activityIndicator.stopAnimating()
        closeMenu()
        mapKitInit()
        
    }
    
    override func viewDidAppear(_ animated: Bool)        {
        if coreDataManager?.categories.count == 0 {
            loadCategories(withPoi: true)
            tableView.delegate = self
            tableView.dataSource = self
        }else{
            
            self.presentAlert(title: "Info", message:"Data Is Already Loaded.!")
        }
    }
    
    //MARK: - DataSet Methods
    
    //MARK: Load  facets JSON and maj coreData Category entity
    
    private func loadCategories(withPoi:Bool = false){
        dataSetService.getFacets(callback:{ result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success( let data):
                    self?.activityIndicator.isHidden = false
                    for facet in data.facets{
                        
                        if facet.name == "categorie" {
                            let categories = facet.facets
                            for categorie in categories{
                                self!.coreDataManager?.addCategorie(name: categorie.name, nbRecords: Int32(categorie.nbRecords),state:categorie.state)
                            }
                            if (withPoi == true){
                                self!.loadPoi()
                            }
                        }
                        continue
                    }
                    
                    break
                case .failure(let error):
                    self?.presentAlert(title: "Error", message:"The facets download failed.:\(error)")
                }}
        })
    }
    
    //MARK: clean GENRE Entities and reLoad  facets JSON and maj coreData Category entity
    
    private func reloadCategories(withPoi:Bool = false){
        activityIndicator.stopAnimating()
        coreDataManager?.deleteAllcategories()
        coreDataManager?.deleteAllpois()
        loadCategories(withPoi: true)
    }
    
    @IBAction func reloadBtnTapped(_ sender: Any) {
        reloadCategories()
    }
    // MARK: Load  Poi JSON and maj coreData Poi entity for all categories
    
    func loadPoi(){
        
        let categories = coreDataManager?.categories as [Genre]?
        guard categories != nil else{return}
        let categorie = coreDataManager?.categories[currentCategoryRank]
        guard categorie != nil else{return}
        guard categorie!.name != nil else{return}
        let nbRecords:Int32 = categorie!.nbRecords
        let nameCategory = categorie!.name
        dataSetService.getPoi(for: nameCategory! , nbRecords:Int(nbRecords),  callback:{ [self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success( let data):
                    self!.coreDataManager?.addPoi(categorie: categorie!, pois: data.records)
                    break
                case .failure(let error):
                    self?.presentAlert(title: "Error", message:"The Poi records download failed.:\(error)")
                }
            }
            if categories!.count >  currentCategoryRank+1{
                
                currentCategoryRank += 1
                loadPoi()
            }else{
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    presentAlert(title: "Info", message:"DataIs Loaded.!")
                    
                }
                
                print (coreDataManager?.categories)
            }
        })
        
        return
    }
}
//MARK: - -------- UITableViewDelegate Extension ---------------

extension MainViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

//MARK: -  MainViewController:UITableViewDataSource Extension

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (coreDataManager?.categories.count)!
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

// MARK: - - MenuDelegate extension

extension  MainViewController:MenuDelegate{
    
    //MARK: button Menu is tapped
    
    @IBAction func menuIsTapped(_ sender: Any) {
        if menuOut == false{
            closeMenu()
        }else{
            
            openMenu()
        }
    }
    
    //MARK: set selected attribute true in the Genre entity
    
    func categoryIsSelected(_ rank:Int){
        coreDataManager?.selectCategory((coreDataManager?.categories[rank])!)
      }
    
    //MARK: set selected attribute false in the Genre entity
    
    func categoryIsUnselected(_ rank:Int){
        coreDataManager?.unselectCategory((coreDataManager?.categories[rank])!)
    }
    
    //MARK: hide menu
    
    func closeMenu(){
        
        
        menuLeadingConstraint.constant = -(view.frame.width*2)
        menuTrailingConstraint.constant = view.frame.width*2
        menuOut = true
        addPoiAnnotation()
    }
    
    //MARK: display menu
    
    func openMenu(){
       
    
        menuLeadingConstraint.constant = 0
        menuTrailingConstraint.constant = view.frame.width/4
        
        menuOut = false
    }
}

//Mark: - extension MapkitDelegate

extension MainViewController:MapkitDelegate,MKMapViewDelegate{
    
    func mapKitInit(){
        let  regionLongitudalMeter = 3500.0
        let  regionLmatitudalMeter = 2500.0
        
        let coordinRegion = MKCoordinateRegion(center:locationBase.coordinate, latitudinalMeters:regionLongitudalMeter,longitudinalMeters:regionLmatitudalMeter)
        mapView.setRegion(coordinRegion, animated: true)
        
    }
    
    //Mark: ANNOTATIONS
    
    func removeAllAnnotation(){
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
    }
    
    func addPoiAnnotation(){
        removeAllAnnotation()
       let  SelectedAnnotations = coreDataManager?.getSelectedCategories()
        guard  SelectedAnnotations!.count > 0 else{return}
    let cat = SelectedAnnotations![0]
        let pois = cat.poi!.allObjects as! [Poi]
       
        for poi in pois{
            let title = poi.name
            let longitude = poi.longitude
            let latitude = poi.latitude
            let address = "adress: \(poi.address ?? "NC.")"
            let email = "email: \(poi.email ?? "NC.")"
            let telephon = "phone: \(poi.telephon ?? "NC.")"
            let info = "\(address) \n \(email) \n\(telephon)"
            let annotation = PoiAnnotation(title: title!, coordinate:CLLocationCoordinate2D(latitude:latitude, longitude: longitude), info: info)
           
            mapView.addAnnotation(annotation)
        }
    }
    
}
