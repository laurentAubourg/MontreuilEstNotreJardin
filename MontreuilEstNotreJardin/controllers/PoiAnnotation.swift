import MapKit
import UIKit

class PoiAnnotation: NSObject, MKAnnotation {
    var title: String?
    var category:String
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(category:String,title: String, coordinate: CLLocationCoordinate2D, info:String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.category = category
    }
}
