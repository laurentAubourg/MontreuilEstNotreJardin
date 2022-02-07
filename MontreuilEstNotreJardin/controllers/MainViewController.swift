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
    
    @IBOutlet weak var  menuTrailingConstraint           : NSLayoutConstraint!
    //  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    
    private let dataSetService:DataSetService = .init()
    private var coreDataManager: CoreDataManager?
    private var currentCategoryRank = 0
    private var currentPoi:Poi?
    private let reuseIdentifier = "cell"
    private var menuOut = false
    private let locationBase = CLLocation(latitude:48.863812, longitude: 2.448451)
    private var removeAnnotatioOnTap = true
    private var locationManager = CLLocationManager.init()
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
        //SegmentControl MapType
        mapSegmentControl.setWidth(30, forSegmentAt: 0)
        mapSegmentControl.setWidth(30, forSegmentAt: 1)
        mapSegmentControl.setWidth(30, forSegmentAt: 2)
    }
    
    //mARK: - Load Category if it is not already done
    
    override func viewDidAppear(_ animated: Bool)        {
        if coreDataManager?.categories.count == 0 {
            loadCategories(withPoi: true)
            tableView.delegate = self
            tableView.dataSource = self
        }else{
            
            //     self.presentAlert(title: "Info", message:"Data Is Already Loaded.!")
        }
    }
    
    //MARK: - ------------------ DataSet Methods ---------------------
    
    //MARK: Load  facets JSON and maj coreData Category entity
    
    private func loadCategories(withPoi:Bool = false){
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
    // MARK: Load  Poi JSON and maj coreData Poi entity for all categories
    
    func loadPoi(){
        
        let categories = coreDataManager?.categories as [Category]?
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
                    //  activityIndicator.stopAnimating()
                    presentAlert(title: "Info", message:"DataIs Loaded.!")
                    
                }
                
                
            }
        })
        
        return
    }
    
    
    //MARK: clean Category Entities and reLoad  facets JSON and maj coreData Category entity
    
    private func reloadCategories(withPoi:Bool = false){
        //   activityIndicator.stopAnimating()
        coreDataManager?.deleteAllcategories()
        coreDataManager?.deleteAllpois()
        loadCategories(withPoi: true)
    }
    
    /* MARK: display favorites annotations
    
    func favoriteBtnTapped() {
        
       let favoritesPois = coreDataManager?.getFavoritesPoi()
        guard favoritesPois != nil else{return}
        
        for poi in favoritesPois!{
            guard poi.category != nil else{continue}
            guard let cat = poi.category else{continue}
            guard let CategoryName = cat.name else{continue}
            let title = poi.name
            let longitude = poi.longitude
            let latitude = poi.latitude
            let address = "adress: \(poi.address ?? "NC.")"
            let email = "email: \(poi.email ?? "NC.")"
            let telephon = "phone: \(poi.telephon ?? "NC.")"
            let info = "\(address) \n \(email) \n\(telephon)!"
            let annotation = PoiAnnotation(category:CategoryName,title: title!, coordinate:CLLocationCoordinate2D(latitude:latitude, longitude: longitude), info: info)
            mapView.addAnnotation(annotation)
   
        }
    }*/
    
}
//MARK: - -------- UITableViewDelegate Extension ---------------

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
    
    //MARK: set selected attribute true in the Category entity
    
    func categoryIsSelected(_ rank:Int){
        coreDataManager?.selectCategory((coreDataManager?.categories[rank])!)
    }
    
    //MARK: set selected attribute false in the Category entity
    
    func categoryIsUnselected(_ rank:Int){
        coreDataManager?.unselectCategory((coreDataManager?.categories[rank])!)
    }
    
    //MARK: hide menu
    
    @objc func closeMenu(){
      
        menuLeadingConstraint.constant = -(view.frame.width*2)
        menuTrailingConstraint.constant = view.frame.width*2
        menuOut = true
        if removeAnnotatioOnTap == true
         {
        addSelectedPoiAnnotation()
       }
    }
    
    //MARK: display menu
    
    func openMenu(){
        
        
        menuLeadingConstraint.constant = 5
        menuTrailingConstraint.constant = view.frame.width/2
        
        menuOut = false
    }
}

//Mark: - ----------- extension MapkitDelegate -----------------

extension MainViewController:MKMapViewDelegate{
    
    func mapKitInit(){
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        locationManager.requestWhenInUseAuthorization()
        
        let  regionLongitudalMeter = 5000.0
        let  regionLmatitudalMeter = 5000.0
        let coordinRegion = MKCoordinateRegion(center:locationBase.coordinate, latitudinalMeters:regionLongitudalMeter,longitudinalMeters:regionLmatitudalMeter)
        mapView.setRegion(coordinRegion, animated: true)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: coordinRegion),animated: true)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance:5000.000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        // create a 3D Camera
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = locationBase.coordinate
        mapCamera.pitch = 0
        mapCamera.altitude = 800
        mapCamera.heading = 30
        
        // set the camera property
        mapView.camera = mapCamera
    }
    
    //Mark: Draws the line between the user's location and the selected point
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        renderer.lineWidth = 5
        return renderer
    }
    
    //Mark: ANNOTATIONS
    
    func removeAllAnnotation(){
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
    }
    
    //MARK; - create an annotation for each category selected
    
    func addSelectedPoiAnnotation(){
        removeAllAnnotation()
        let  SelectedAnnotations = coreDataManager?.getSelectedCategories()
        guard  SelectedAnnotations!.count > 0 else{return}
        
        for cat:Category in Array(SelectedAnnotations!){
            let pois = cat.poi!.allObjects as! [Poi]
            
            guard cat.name != nil else{return}
            for poi in pois{
                let annotation = createAnotation(poi: poi,category: cat)
                addAnnotation(annotation: annotation)
            }
        }
    }
    
    //MARK: -Create an annotation for the point passed in parameter
    
    func createAnotation(poi:Poi,category:Category)->PoiAnnotation{
        let title = poi.name
        let longitude = poi.longitude
        let latitude = poi.latitude
        let address = "adresse: \(poi.address ?? "NC.")"
        let email = "email: \(poi.email ?? "NC.")"
        let telephon = "phone: \(poi.telephon ?? "NC.")"
        let info = "\(address) \n \(email) \n\(telephon)!"
        let annotation = PoiAnnotation(category:category.name!,title: title!, coordinate:CLLocationCoordinate2D(latitude:latitude, longitude: longitude), info: info)
        return annotation
    }
    func addAnnotation(annotation:PoiAnnotation){
        mapView.addAnnotation(annotation)
    }
    //MARK: get Poi entity where longitude and latitude parameers corresponding to those sought
    
    func getPoiByLocation(longitude:Double,latitude:Double)->Poi?{
        let poi = coreDataManager?.getPoiByLocation(longitude: longitude, latitude: latitude)
        return poi
    }
    
    //MARK MapView delegate method display annotation
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is PoiAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        let poiCategoryName =  (annotation as! PoiAnnotation).category
        let pinImage = UIImage(named: coreDataManager?.getCategoryPinIcon(poiCategoryName) ?? "" )
        annotationView!.image = pinImage
        annotationView!.canShowCallout = true
        annotationView!.calloutOffset = CGPoint(x: -5, y: 5)
        annotationView!.rightCalloutAccessoryView = UIButton(type:.infoLight)
        
        return annotationView
    }
    
    // MARK: - alert Info when clic annotation button
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let poiCoordinate = (view.annotation as! PoiAnnotation).coordinate
        currentPoi = getPoiByLocation(longitude: poiCoordinate.longitude, latitude: poiCoordinate.latitude)
        performSegue(withIdentifier: "annotationsInfos", sender: nil)
    }
    
    //MARK: - PopUp Segue
    
    override   func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "annotationsInfos"
        {
            let vc = segue.destination as! infosViewController
            vc.poi = currentPoi
            vc.delegate = self
            
        }else if(segue.identifier == "showDelegate"){
            
            removeAnnotatioOnTap = false
            let vc = segue.destination as! FavoriteViewController
            vc.delegate = self
        }
    }
    
    // MARK: - Add a place to the list of favorites
    
    func addPoiToFavorit(){
        if currentPoi?.favorit == true{
            coreDataManager?.removePoiToFavorit(currentPoi)
            return
        }
        coreDataManager?.addPoiToFavorit(currentPoi)
    }
    
    //MARK: - Traces the path from the user's position to the selected location
    
    func tracePath(){
        mapView.removeOverlays(mapView.overlays)
       guard let request = getRequestDirection() else { return }
        request.transportType = .walking
        request.requestsAlternateRoutes = false
      let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (response, error) in
            guard let response = response else { return }
            let paths = response.routes
            for path in paths {
                self.mapView.addOverlay(path.polyline)
                self.mapView.setVisibleMapRect(path.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    // MARK: - create and return a direction request
    
    func getRequestDirection()->MKDirections.Request?{
        guard let coordinate = locationManager.location?.coordinate else { return nil }
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        let origin = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: origin)
        request.destination = MKMapItem(placemark: destination)
        return request
    }
    
    //MARK: - return the center point coordinate of the map
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let coordinates = mapView.centerCoordinate
        return CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    //  MARK: - Changes the type of view according to the button selected in the segmentControl
    
    @IBAction func typeViewSegmentChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = mapView.centerCoordinate
        mapCamera.altitude = mapView.camera.altitude
        switch selectedIndex{
        case 0:
            mapView.mapType = .mutedStandard
            mapCamera.pitch = 10
            break
        case 1:
            
            mapCamera.pitch = 45
            mapView.mapType = .mutedStandard
            break
        case 2:mapView.mapType = .satelliteFlyover
            mapView.camera = mapCamera
        default: mapView.mapType = .standard
            break
            
        }
        mapView.camera = mapCamera
    }
    
    //MARK - positions the map at the user's location
    
    @IBAction func locationBtnTapped(_ sender: UIBarButtonItem) {
        let span = MKCoordinateSpan.init(latitudeDelta: 0.0075, longitudeDelta: 0.0075)
        guard let location = locationManager.location else{return}
        let region = MKCoordinateRegion.init(center:(location.coordinate),span:span)
        mapView.setRegion(region, animated: true)
        
    }
    
    //MARK: - Zoom on a selected point
    
    func zoomPoi(poi:Poi){
        let locationPoi = CLLocation(latitude:poi.latitude, longitude:poi.longitude)
        let  regionLongitudalMeter = 10.0
        let  regionLmatitudalMeter = 10.0
        // mapView.mapType = .satelliteFlyover
        let coordinRegion = MKCoordinateRegion(center:locationPoi.coordinate, latitudinalMeters:regionLongitudalMeter,longitudinalMeters:regionLmatitudalMeter)
        mapView.setRegion(coordinRegion, animated: true)
        
    }
    
}
