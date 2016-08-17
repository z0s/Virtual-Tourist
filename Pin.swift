//
//  Pin.swift
//  VirtualTourist
//
//  Created by IT on 8/11/16.
//  Copyright © 2016 z0s. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {

// Insert code here to add functionality to your managed object subclass
    private var coordinates: CLLocationCoordinate2D?
    var coordinate: CLLocationCoordinate2D {
        
        set {
            willChangeValueForKey("coordinate")
            coordinates = newValue
            
            // set the new values of the lat and long
            if let coord = coordinates {
                latitude = coord.latitude
                longitude = coord.longitude
            }
            
            didChangeValueForKey("coordinate")
        }
        
        get {
            if coordinates == nil {
                coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            }
            
            return coordinates!
        }
    }
    
    var title: String? = nil
    var subtitle: String? = nil
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
        
        coordinate = CLLocationCoordinate2DMake(latitude as CLLocationDegrees, longitude as CLLocationDegrees)
    }
}

