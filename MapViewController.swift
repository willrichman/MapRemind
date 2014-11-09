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
    var overlays = [MKOverlay]()
    var annotations = [MKAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        self.coreDataHandler = CoreDataHandler(context: self.managedObjectContext!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reminderAdded:", name: "REMINDER_ADDED", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reminderDeleted:", name: "REMINDER_DELETED", object: nil)
        
        self.locationManager.delegate = self

        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressMap:")
        self.mapView.addGestureRecognizer(longPress)
        
        if let reminders = self.coreDataHandler?.fetchReminders() {
            for reminder in reminders {
                let coordinate = CLLocationCoordinate2D(latitude: reminder.latitude, longitude: reminder.longitude)
                let overlay = MKCircle(centerCoordinate: coordinate, radius: reminder.radius)
                self.mapView.addOverlay(overlay)
                self.overlays.append(overlay)
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = reminder.userText
                self.mapView.addAnnotation(annotation)
                self.annotations.append(annotation)
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
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if let circularRegion = region as? CLCircularRegion {
            if (UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
                let notification = UILocalNotification()
                notification.alertBody = "You trigger a notification!"
                UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            }
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
        if annotation.title == "Add a reminder?" {
            let addButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
            annotationView.rightCalloutAccessoryView = addButton
        } else {
            let detailsButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
            annotationView.rightCalloutAccessoryView = detailsButton
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let buttonTapped = control as UIButton
        if buttonTapped.buttonType == UIButtonType.ContactAdd {
            let reminderVC = self.storyboard?.instantiateViewControllerWithIdentifier("REMINDER_VC") as AddReminderViewController
            reminderVC.locationManager = self.locationManager
            reminderVC.selectedAnnotation = view.annotation
            reminderVC.coreDataHandler = self.coreDataHandler
            self.presentViewController(reminderVC, animated: true) { () -> Void in
            }
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.3)
        renderer.lineWidth = 1.0
        return renderer
    }
    
    //MARK: - Notification Center Selectors
    
    func reminderAdded(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let geoRegion = userInfo["region"] as CLCircularRegion
        let name = userInfo["name"] as String
        let overlay = MKCircle(centerCoordinate: geoRegion.center, radius: geoRegion.radius)
        self.mapView.addOverlay(overlay)
        self.overlays.append(overlay)
        var annotation = MKPointAnnotation()
        annotation.coordinate = geoRegion.center
        annotation.title = name
        self.mapView.addAnnotation(annotation)
        self.annotations.append(annotation)
    }
    
    func reminderDeleted(notification: NSNotification) {
        let notificationInfo = notification.userInfo!
        let regionToDelete = notificationInfo["reminder"] as Reminder
        for region in self.locationManager.monitoredRegions {
            if region.identifier == regionToDelete.identifier {
                self.locationManager.stopMonitoringForRegion(region as CLRegion)
                println("region deleted")
            }
        }
        for overlay in overlays {
            if overlay.coordinate.latitude == regionToDelete.latitude && overlay.coordinate.longitude == regionToDelete.longitude {
                self.mapView.removeOverlay(overlay)
            }
        }
        for annotation in annotations {
            if annotation.coordinate.latitude == regionToDelete.latitude && annotation.coordinate.longitude == regionToDelete.longitude {
                self.mapView.removeAnnotation(annotation)
            }
        }
    }
}
