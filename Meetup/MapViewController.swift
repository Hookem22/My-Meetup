import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var venue: Venue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Map"
        
        if let venue = self.venue as Venue! {
            
            let region = MKCoordinateRegionMakeWithDistance(venue.coordinate, 2000, 2000)
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(venue)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


