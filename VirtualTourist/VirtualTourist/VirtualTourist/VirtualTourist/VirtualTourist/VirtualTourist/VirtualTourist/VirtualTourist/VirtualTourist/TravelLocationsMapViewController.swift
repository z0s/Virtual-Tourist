//
//  TravelLocationMapsViewController.swift
//  VirtualTourist
//
//  Created by IT on 8/7/16.
//  Copyright © 2016 z0s. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapsViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var removePinLabel: UILabel?
    @IBOutlet var mapBottomConstraint: NSLayoutConstraint!
    
    let stack = (UIApplication.sharedApplication().delegate as! AppDelegate).stack
    
    var mapPinToPinLabelConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        title = "Virtual Tourist"
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        mapPinToPinLabelConstraint = mapView.bottomAnchor.constraintEqualToAnchor(removePinLabel?.topAnchor)
        // Do any additional setup after loading the view, typically from a nib.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
        longPressGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGesture)
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            if let pins =  try stack.context.executeFetchRequest(fetchRequest) as? [Pin] {
                mapView.addAnnotations(pins)
            }
        } catch {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        UIView.animateWithDuration(0.5) {
            self.removePinLabel?.hidden = !editing
            self.mapBottomConstraint.active = !editing
            self.mapPinToPinLabelConstraint.active = editing
        }
    }
    
    //MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if self.editing {
            // Remove pin from mapView and Core Data
            let pin = view.annotation as! Pin
            mapView.removeAnnotation(pin)
            stack.context.deleteObject(pin)
            stack.saveContext()
            mapView.layoutIfNeeded()
        } else {
            let photoAlbumVC = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            let pin = view.annotation as! Pin
            photoAlbumVC.pin = pin
            navigationController?.pushViewController(photoAlbumVC, animated: true)
        }
    }
    
    var pin: Pin? = nil
    
    func addPin(gesture: UILongPressGestureRecognizer) {
        let locationInMap = gesture.locationInView(mapView)
        let coord: CLLocationCoordinate2D = mapView.convertPoint(locationInMap, toCoordinateFromView: mapView)
        
        
        switch gesture.state {
        case .Began:
            pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: stack.context)
            mapView.addAnnotation(pin!)
        case .Changed:
            pin?.coordinate = coord
        case .Ended:
            FlickrAPI.requestImagesAtPin(pin!, completion: { (results, error) in
                if results.count > 0 {
                    self.pin?.photos = self.pin!.photos!.setByAddingObjectsFromArray(results)
                }
            })
        default:
            return
        }
        
        stack.saveContext()
    }

}

