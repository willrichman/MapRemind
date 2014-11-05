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

class AddReminderViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager : CLLocationManager!
    var selectedAnnotation : MKAnnotation!
    var mapRegion : MKCoordinateRegion?
    var coreDataHandler : CoreDataHandler?
    var reminderRadius = 500.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapRegion = MKCoordinateRegionMakeWithDistance(self.selectedAnnotation.coordinate, self.reminderRadius * 2, self.reminderRadius * 3)
        self.mapView.centerCoordinate = self.selectedAnnotation.coordinate
        self.mapView.setRegion(self.mapRegion!, animated: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let overlay = MKCircle(centerCoordinate: self.selectedAnnotation.coordinate, radius: self.reminderRadius)
        self.mapView.addOverlay(overlay)
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        renderer.lineWidth = 1.0
        return renderer
    }

    @IBAction func didPressSaveReminderButton(sender: AnyObject) {
        var geoRegion = CLCircularRegion(center: selectedAnnotation.coordinate, radius: self.reminderRadius, identifier: "TestRegion")
        self.locationManager .startMonitoringForRegion(geoRegion)
        self.coreDataHandler?.saveReminder("Default", radius: geoRegion.radius, coordinate: geoRegion.center)
        
        NSNotificationCenter.defaultCenter().postNotificationName("REMINDER_ADDED", object: self, userInfo: ["region": geoRegion])
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        
    }
    
    @IBAction func didPressCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
}
