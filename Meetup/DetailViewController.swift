import UIKit
import EventKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            if let detailItem = detailItem {
                nameLabel.text = detailItem.name
            }
        }
    }
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            if let detailItem = detailItem {
                timeLabel.text = detailItem.formattedDateTime
            }
        }
    }
    @IBOutlet weak var addressNameLabel: UILabel! {
        didSet {
            if let detailItem = detailItem {
                addressNameLabel.text = detailItem.venue.title
            }
        }
    }
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            if let detailItem = detailItem {
                addressLabel.text = detailItem.venue.subtitle
            }
        }
    }
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            if let detailItem = detailItem {
                priceLabel.text = detailItem.price
            }
        }
    }
    @IBOutlet weak var goingLabel: UILabel! {
        didSet {
            if let detailItem = detailItem {
                goingLabel.text = "\(detailItem.rsvpYes) \(detailItem.groupUserLabel) going"
            }
        }
    }
    @IBOutlet weak var descriptionView: UIWebView! {
        didSet {
            if let detailItem = detailItem {
                descriptionView.backgroundColor = UIColor.clearColor();
                descriptionView.loadHTMLString(detailItem.description, baseURL: nil)
            }
        }
    }
    @IBOutlet weak var rsvpButton: UIButton!
    
    var detailItem: Event?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
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
        if (segue.identifier == "showMap" ) {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MapViewController
            controller.venue = self.detailItem?.venue
        }
        
    }
    
    @IBAction func rsvpButtonClick(sender: UIButton) {
        
        MeetupUser.getCurrentUser { currentUser in
            if let user = currentUser as MeetupUser! {
                user.joinEvent(self.detailItem!)
                
                //Update UI
            }
            else {
                if let url = MeetupUser.authorizeUrl as String! {
                    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                } else {
                    print("Enter Meetup API Key in MasterViewController")
                }
            }
        }
    }
    
    func getAccessToken(code: String) {
        MeetupUser.getAccesToken(code, completionHandler: { meetupUser in

        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

