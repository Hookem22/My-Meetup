import SwiftyJSON
import MapKit

class Venue : NSObject, MKAnnotation {
    var title: String?
    let coordinate: CLLocationCoordinate2D
    let address: String
    let city: String
    let state: String
    let zip: String
    var subtitle: String? {
        return "\(self.address), \(self.city), \(self.state), \(self.zip)"
    }
    
    init(_ json: JSON) {
        self.title = json["name"].stringValue
        let lat = json["lat"].doubleValue
        let lon = json["lon"].doubleValue
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.address = json["address_1"].stringValue
        self.city = json["city"].stringValue
        self.state = json["state"].stringValue
        self.zip = json["zip"].stringValue

        super.init()
    }
}
