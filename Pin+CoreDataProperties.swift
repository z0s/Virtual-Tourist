//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by IT on 8/16/16.
//  Copyright © 2016 z0s. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var currentPage: Int
    @NSManaged var photos: NSSet?

}
