//
//  ReminderTableViewController.swift
//  MapRemind
//
//  Created by William Richman on 11/5/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit
import CoreData

class ReminderTableViewController: UIViewController, UITableViewDataSource {

    var managedObjectContext : NSManagedObjectContext?
    var coreDataHandler : CoreDataHandler?
    var reminders = [Reminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        self.coreDataHandler = CoreDataHandler(context: self.managedObjectContext!)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("REMINDER_CELL", forIndexPath: indexPath) as? UITableViewCell
        cell?.textLabel.text = self.reminders[indexPath.row].identifier
        return cell!
    }

}
