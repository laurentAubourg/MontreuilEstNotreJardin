//
//  MainViewController.MapKitDelegat.extension.swif.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 08/02/2022.
//

import MapKit
import CoreLocation

//MARK: - -----------  MapkitDelegate EXTENSION MKMapViewDelegate-----------------

extension MainViewController:MKMapViewDelegate{
  
    // MARK: - initialize the mapView
    func mapKitInit(){
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.isPitchEnabled = true
        locationManager.requestWhenInUseAuthorization()
        let  regionLongitudalMeter = 5000.0
        let  regionLmatitudalMeter = 5000.0
        let coordinRegion = MKCoordinateRegion(center:locationBase.coordinate, latitudinalMeters:regionLongitudalMeter,longitudinalMeters:regionLmatitudalMeter)
        mapView.setRegion(coordinRegion, animated: true)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: coordinRegion),animated: true)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance:1000.000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        // create a 3D Camera
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = locationBase.coordinate
        mapCamera.altitude = 500
        // set the camera property
        mapView.camera = mapCamera
        mapView?.showsTraffic = false
    }
    
    //Mark: remove an annotation on the mapView
    
    func removeAllAnnotation(){
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
    }
    
    //MARK; - create an annotation for each category selected
    
    func addSelectedPoiAnnotation(){
        removeAllAnnotation()
        closePath()
        let  SelectedAnnotations = coreDataManager?.selectedCategories
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
    
    //MARK add an annotation on the mapView
    
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
    
    //MARK: - function launched when a segment is called
    
    override   func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "annotationsInfos"
        {
            let vc = segue.destination as! detailPoiViewController
            vc.modalPresentationStyle = .formSheet
            vc.preferredContentSize = .init(width: 500, height: 350)
            vc.poi = currentPoi
            vc.delegate = self
            
        }else if(segue.identifier == "showDelegate"){
            
            removeAnnotatioOnTap = false
            let vc = segue.destination as! FavoritViewController
            vc.delegate = self
        }
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
        let coordinRegion = MKCoordinateRegion(center:locationPoi.coordinate, latitudinalMeters:regionLongitudalMeter,longitudinalMeters:regionLmatitudalMeter)
        mapView.setRegion(coordinRegion, animated: true)
        
    }
    
    // MARK: - create and return a direction request
    
    func getRequestDirection()->MKDirections.Request?{
        guard let coordinate = locationManager.location?.coordinate else { return nil }
        guard let poi = currentPoi else{return nil}
        let destinationCoordinate = CLLocationCoordinate2D(latitude:poi.latitude, longitude: poi.longitude)
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
    
    
    //MARK: - Traces the path from the user's position to the selected location
    
    func tracePath(){
        self.pathInstruction = []
        removePath()
        // Delete annotations before adding new ones
        mapView.removeAnnotations(mapView.annotations)
       // Adds new annotations
        let annotation = self.createAnotation(poi: currentPoi!,category: (currentPoi?.category)!)
        addAnnotation(annotation: annotation)
        guard let request = getRequestDirection() else { return }
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (response, error) in
            guard let response = response else { return }
            let paths = response.routes
           
            for path in paths {
                self.mapView.addOverlay(path.polyline)
                self.mapView.setVisibleMapRect(path.polyline.boundingMapRect,edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
                let steps  = Array(path.steps)
                for step in steps{
                    if step.distance > 0{
                        self.pathInstruction.append("dans \(step.distance.rounded() ) mètres \(step.instructions) " )
                        
                    }else{
                        self.pathInstruction.append("\(step.instructions) " )
                    }
                    self.pathCoordinate.append(step.polyline.coordinate)
                    }
                
                openpath()
                pthBtn.isHidden = false
                pathTableView.reloadData()
              
            }
        }
     
    }
    
    //Mark: Draws the line between the user's location and the selected point
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        renderer.lineWidth = 5
        return renderer
    }
  
    //MARK: remove the path on the map
    
    func removePath(){
        mapView.removeOverlays(mapView.overlays)
    }
    
    // MARK: - change the map display in satellite standard
    
    @IBAction func mode2DTapped(_ sender: Any) {
        
        mapView.camera.centerCoordinate = mapView.centerCoordinate
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.mapType = .standard
        mapView.camera.pitch = 0
        
    }
    
    // MARK: - change the map display in satellite mode
    
    @IBAction func modeStaliteTapped(_ sender: Any) {
        mapView.camera.centerCoordinate = mapView.centerCoordinate
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.mapType = .hybridFlyover
        mapView.camera.pitch = 240
    }
}
public extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}
