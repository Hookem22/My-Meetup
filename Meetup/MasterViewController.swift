//
//  MasterViewController.swift
//  Meetup
//
//  Created by Will Parks on 3/22/16.
//  Copyright © 2016 Pow Wow. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Event]()


    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("MEETUP_NAME", forKey: "MeetupGroupName")
        defaults.setObject("MEETUP_API_KEY", forKey: "MeetupAPIKey")
        
        self.title = "Tech ^map"
        navigationController?.navigationBar.barTintColor = UIColor.hex("E0393E")
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

