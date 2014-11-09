//
//  Reminder.swift
//  MapRemind
//
//  Created by William Richman on 11/4/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import CoreData

class Reminder: NSManagedObject {
    
    @NSManaged var identifier : String
    @NSManaged var date : NSDate
    @NSManaged var radius : Double
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var userText : String
    
}