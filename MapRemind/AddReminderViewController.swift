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
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager : CLLocationManager!
    var selectedAnnotation : MKAnnotation!
    var mapRegion : MKCoordinateRegion?
    var mapSpan : MKCoordinateSpan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        self.mapRegion = MKCoordinateRegion(center: self.selectedAnnotation.coordinate, span: self.mapSpan!)
        self.mapView.centerCoordinate = self.selectedAnnotation.coordinate
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.mapView.setRegion(self.mapRegion!, animated: true)
    }

    @IBAction func didPressSaveReminderButton(sender: AnyObject) {
        var geoRegion = CLCircularRegion(center: selectedAnnotation.coordinate, radius: 100.0, identifier: "TestRegion")
        self.locationManager .startMonitoringForRegion(geoRegion)
        
        NSNotificationCenter.defaultCenter().postNotificationName("REMINDER_ADDED", object: self, userInfo: ["region": geoRegion])
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        
    }
    
    @IBAction func didPressCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    
    
}
