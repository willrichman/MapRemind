//
//  MapViewController.swift
//  MapRemind
//
//  Created by William Richman on 11/3/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var managedObjectContext : NSManagedObjectContext?
    var coreDataHandler : CoreDataHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        self.coreDataHandler = CoreDataHandler(context: self.managedObjectContext!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reminderAdded:", name: "REMINDER_ADDED", object: nil)
        
        self.locationManager.delegate = self

        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressMap:")
        self.mapView.addGestureRecognizer(longPress)
        
        if let reminders = self.coreDataHandler?.fetchReminders() {
            for reminder in reminders {
                
            }
        }
        
        switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus {
        case .Authorized:
            println("authorized")
            self.mapView.showsUserLocation = true
        case .NotDetermined:
            println("not determined")
            self.locationManager.requestAlwaysAuthorization()
        case .Restricted:
            println("restricted")
        case .Denied:
            println("denied")
        default:
            println("default")
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - LocationManagerDelegate methods
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            self.locationManager.startUpdatingLocation()
        default:
            println("default on authorization check")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            //println("\(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    //MARK: - Gesture methods
    
    func didLongPressMap(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let touchPoint = sender.locationInView(self.mapView)
            let touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            println("\(touchCoordinate.latitude), \(touchCoordinate.longitude)")
            var annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Add a reminder?"
            self.mapView.addAnnotation(annotation)
        }
    }

    //MARK: - MapViewDelegate methods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "ANNOTATION")
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        let addButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
        annotationView.rightCalloutAccessoryView = addButton
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let reminderVC = self.storyboard?.instantiateViewControllerWithIdentifier("REMINDER_VC") as AddReminderViewController
        reminderVC.locationManager = self.locationManager
        reminderVC.selectedAnnotation = view.annotation
        reminderVC.coreDataHandler = self.coreDataHandler
        self.presentViewController(reminderVC, animated: true) { () -> Void in
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        renderer.lineWidth = 1.0
        return renderer
    }
    
    //MARK: - Notification Center Selectors
    
    func reminderAdded(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let geoRegion = userInfo["region"] as CLCircularRegion
        let overlay = MKCircle(centerCoordinate: geoRegion.center, radius: geoRegion.radius)
        self.mapView.addOverlay(overlay)
    }
    
}
