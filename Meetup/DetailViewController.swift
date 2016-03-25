import UIKit
import EventKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var goingLabel: UILabel!
    @IBOutlet weak var descriptionView: UIWebView!
    
    var detailItem: Event?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        
        if let event = self.detailItem as Event! {
            if let nameLabel = self.nameLabel {
                nameLabel.text = event.name
            }
            if let timeLabel = self.timeLabel {
                timeLabel.text = event.formattedDateTime
            }
            if let addressNameLabel = self.addressNameLabel {
                addressNameLabel.text = event.venue.title
            }
            if let addressLabel = self.addressLabel {
                addressLabel.text = event.venue.subtitle
            }
            if let priceLabel = self.priceLabel {
                priceLabel.text = event.price
            }
            if let goingLabel = self.goingLabel {
                goingLabel.text = "\(event.rsvpYes) \(event.groupUserLabel) going"
            }
            if let descriptionView = self.descriptionView {                
                descriptionView.backgroundColor = UIColor.clearColor();
                descriptionView.loadHTMLString(event.description, baseURL: nil)
            }
        }
    }
    

    @IBAction func timeButtonClick(sender: UIControl) {
        let eventStore = EKEventStore()
        
        let status = EKEventStore.authorizationStatusForEntityType(.Event)
        if (status == .Denied) {
            let alertController = UIAlertController(title: "Calendar Permissions", message:
                "Access to your calendar was denied. You can change permissions in your phone settings.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if (status != .Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                self.createEvent(eventStore)
            })
        }
        else {
            self.createEvent(eventStore)
        }
    }
    
    func createEvent(eventStore: EKEventStore) {
        let event = EKEvent(eventStore: eventStore)
        if let detail = self.detailItem as Event! {
        
            print(detail.startDate)
            print(detail.endDate)
            
            event.title = detail.name
            event.startDate = detail.startDate
            event.endDate = detail.endDate
            event.timeZone = NSTimeZone(forSecondsFromGMT: detail.utcOffset)
            event.calendar = eventStore.defaultCalendarForNewEvents
            do {
                try eventStore.saveEvent(event, span: .ThisEvent)
                
                let alertController = UIAlertController(title: "Added to Calendar", message:
                    "\(event.title) has been added to your calendar", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            } catch {
                print("Error: Adding Event to Calendar")
            }
        }
    }
    
    @IBAction func addressButtonClick(sender: UIControl) {
        performSegueWithIdentifier("showMap", sender: view)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showMap" )
        {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MapViewController
            controller.venue = self.detailItem?.venue
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

