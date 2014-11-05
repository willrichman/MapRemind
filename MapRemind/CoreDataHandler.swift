//
//  CoreDataHandler.swift
//  MapRemind
//
//  Created by William Richman on 11/4/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import CoreData
import MapKit

class CoreDataHandler {
    
    var managedObjectContext : NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func saveReminder(name: String, radius: Double, coordinate: CLLocationCoordinate2D) {
        var reminderToSave = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.managedObjectContext) as Reminder
        reminderToSave.identifier = name
        reminderToSave.radius = radius
        reminderToSave.date = NSDate()
        reminderToSave.latitude = coordinate.latitude
        reminderToSave.longitude = coordinate.longitude
        
        var error: NSError?
        self.managedObjectContext.save(&error)
        
        if error != nil {
            println(error?.localizedDescription)
        }
    }
    
    func fetchReminders() -> [Reminder]? {
        var fetchRequest = NSFetchRequest(entityName: "Reminder")
        var error : NSError?
        let fetchResults = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        if let reminders = fetchResults as? [Reminder] {
            println("reminders: \(reminders.count)")
            return reminders
        }
        return nil
    }
    
}
