//
//  ViewController.swift
//  mapTest
//
//  Created by laurent aubourg on 06/01/2022.
//

import UIKit
import MapKit

class JardinsViewController: UIViewController{
    
    @IBOutlet weak var mapJardins: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapJardins.delegate = self
        let locationBase = CLLocation(latitude:48.863507755484214, longitude: 2.4486559017)
        let  regionLongitudalMeter = 3000.0
        let  regionLmatitudalMeter = 1000.0
        
        let coordinRegion = MKCoordinateRegion(center:locationBase.coordinate, latitudinalMeters:regionLongitudalMeter,longitudinalMeters:regionLmatitudalMeter)
        mapJardins.setRegion(coordinRegion, animated: true)
    }
}
extension JardinsViewController: MKMapViewDelegate {
    
}
