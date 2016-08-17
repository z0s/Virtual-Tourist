//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by IT on 8/14/16.
//  Copyright © 2016 z0s. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var id: NSNumber?
    @NSManaged var url: String?
    @NSManaged var imageData: NSData?
    @NSManaged var pin: Pin?

}
