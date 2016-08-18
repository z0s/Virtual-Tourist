//
//  Pin.swift
//  VirtualTourist
//
//  Created by IT on 8/11/16.
//  Copyright © 2016 z0s. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation


class Pin: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    var coordinate: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        
        get {
           return CLLocationCoordinate2DMake(latitude, longitude)
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
    }
}

