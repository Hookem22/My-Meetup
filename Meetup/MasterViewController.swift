
import UIKit

class MasterViewController: UITableViewController {

    let AppTitle = "Tech ^map"
    let MeetupName = "CoFounder-Austin"
    let MeetupAPIKey = "423761707442d79542e645e4120158"
    let HeaderColor = "E0393E"
    
    var detailViewController: DetailViewController? = nil
    var objects = [Event]()


    override func viewDidLoad() {
        super.viewDidLoad()

        KeychainWrapper.setString(MeetupName, forKey: "MeetupGroupName")
        KeychainWrapper.setString(MeetupAPIKey, forKey: "MeetupAPIKey")
        
        self.title = AppTitle
        navigationController?.navigationBar.barTintColor = UIColor.hex(HeaderColor)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        Event.get { events in
            self.objects = events
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventCell

        let event = objects[indexPath.row] as Event
        cell.nameLabel.text = event.name
        cell.dateLabel.text = event.formattedDate
        cell.timeLabel.text = event.formattedTime
        cell.rsvpLabel.text = "\(event.rsvpYes) \(event.groupUserLabel)"
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}

