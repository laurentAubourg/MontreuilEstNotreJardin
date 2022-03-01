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
    
    @IBOutlet weak var pthBtn: UIButton!
    @IBOutlet weak var pathTableView: UITableView!
    @IBOutlet weak var categorieTableView: UITableView!
    @IBOutlet weak var pathView: UIView!
    @IBOutlet weak var pathLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pathTrailingConstraint           : NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuTrailingConstraint           : NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    
    private let dataSetService:DataSetService = .init()
    var coreDataManager: CoreDataManager?
    private var currentCategoryRank = 0
    private let reuseIdentifier = "cell"
    private let reuseIdentifierPath = "cellPath"
    private var menuOut = false
    private var pathOut = false
    var pathInstruction: Array<String> = []
    var pathCoordinate :Array<CLLocationCoordinate2D> = []
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
        categorieTableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        // pathTableView
        let nibPath = UINib(nibName: "InstructionsTableViewCell", bundle: nil)
        pathTableView.register(nibPath, forCellReuseIdentifier: reuseIdentifierPath)
        //coreData
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        coreDataManager = CoreDataManager(coreDataStack:appdelegate.coreDataStack)
        //menu
        closeMenu()
        //PATH
        closePath()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeMenu))
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeMenu), name: UIDevice.orientationDidChangeNotification, object: nil)
        mapView.addGestureRecognizer(tap)
        //mapKit
        mapKitInit()
    }
    
    //MARK: - ------------- METHODS ------------------------------
    
    //MARK: - Load Category if it is not already done
    
    override func viewDidAppear(_ animated: Bool)        {
        if coreDataManager?.categories.count == 0 {
            categorieTableView.delegate = self
            categorieTableView.dataSource = self
            pathTableView.delegate = self
            pathTableView.dataSource = self
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
}
//MARK: - ----------------- MENU UITableView DELEGATE EXTENSION

//MARK: - activate or deactivate the checkBox button of the cell

extension MainViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView{
        case categorieTableView:
            guard let category = coreDataManager?.categories[indexPath.row] else{return}
            if(category.selected == true){
                coreDataManager?.unselectCategory(category)
            }else{
                coreDataManager?.selectCategory(category)
            }
            tableView.reloadData()
        case pathTableView:
            let  regionLongitudalMeter = 10.0
            let  regionLmatitudalMeter = 10.0
            let coordinRegion = MKCoordinateRegion(center:pathCoordinate[indexPath.row], latitudinalMeters:regionLongitudalMeter,longitudinalMeters:regionLmatitudalMeter)
            mapView.setRegion(coordinRegion, animated: true)
                       
            closePath()
        default:   tableView.reloadData()
        }
    }   
}

//MARK: -  -------- TableViewDataSource Extension ---------------

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView{
        case categorieTableView:
            return (coreDataManager?.categories.count) ?? 0
        case pathTableView:
            return self.pathInstruction.count
        default: return 0
        }
        
    }
    
    // MARK: - Filling the tableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView{
        case self.categorieTableView:
            let item = coreDataManager?.categories[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)! as! MenuTableViewCell
            cell.delegate = self
            cell.titleLab.text = item!.name
            cell.checkBoxBtn.tag = indexPath.row
            cell.checkBoxBtn.isSelected = ((item?.selected) == true)
            cell.textLabel?.textColor = UIColor.white
            return cell
        case self.pathTableView:
            let item = pathInstruction[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierPath)! as! InstructionsTableViewCell
            cell.titleLab.text = item
            return cell
        default: let cell =   UITableViewCell()
            return cell
        }
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
    //MARK: - hide Path
    
    @objc func closePath(){
        
        pathLeadingConstraint.constant = -(view.frame.width)
        pathTrailingConstraint.constant = view.frame.width
        pathOut = true
        
    }
    
    //MARK: - display path
    
    func openpath(){
        
        pathLeadingConstraint.constant = 5
        pathTrailingConstraint.constant = view.frame.width/2
        pathOut = false
    }
    
    //MARK: - when pathBtn is ta^êd cole ot open the path panet
    
    @IBAction func pthBtnTapped(_ sender: Any) {
        if pathOut {
            pthBtn.isSelected = true
            openpath()
        }else{
            pthBtn.isSelected = false
            closePath()
        }
    }
}
