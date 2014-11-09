//
//  ReminderTableViewController.swift
//  MapRemind
//
//  Created by William Richman on 11/5/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit
import CoreData

class ReminderTableViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    var coreDataHandler : CoreDataHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        self.coreDataHandler = CoreDataHandler(context: self.managedObjectContext!)
        
        self.tableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetCloudChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: appDelegate.persistentStoreCoordinator)
        
        var fetchRequest = NSFetchRequest(entityName: "Reminder")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Reminders")
        self.fetchedResultsController.delegate = self
        
        var error : NSError?
        if !self.fetchedResultsController.performFetch(&error) {
            println("error!!")
        }
        
    }
    
    //MARK: Table view datasource methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("REMINDER_CELL", forIndexPath: indexPath) as? UITableViewCell
        let reminder = self.fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder
        cell?.textLabel.text = reminder.userText
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let reminderToDelete = self.fetchedResultsController.objectAtIndexPath(indexPath) as Reminder
            NSNotificationCenter.defaultCenter().postNotificationName("REMINDER_DELETED", object: self, userInfo: ["reminder": reminderToDelete])
            self.managedObjectContext.deleteObject(reminderToDelete)
            var error: NSError?
            self.managedObjectContext.save(&error)
            if error != nil {
                println(error?.localizedDescription)
            }

        }
    }
    
    //MARK: iCloud Notification handlers
    
    func didGetCloudChanges( notification : NSNotification)
    {
        self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
    }

    //MARK: FetchedResultsController methods
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
}
