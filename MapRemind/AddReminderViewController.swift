//
//  AddReminderViewController.swift
//  MapRemind
//
//  Created by William Richman on 11/3/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddReminderViewController: UIViewController {
    
    var locationManager : CLLocationManager!
    var selectedAnnotation : MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func didPressSaveReminderButton(sender: AnyObject) {
        var geoRegion = CLCircularRegion(center: selectedAnnotation.coordinate, radius: 100.0, identifier: "TestRegion")
        
        self.locationManager .startMonitoringForRegion(geoRegion)
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    @IBAction func didPressCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
}
