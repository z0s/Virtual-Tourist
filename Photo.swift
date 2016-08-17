//
//  Photo.swift
//  VirtualTourist
//
//  Created by IT on 8/14/16.
//  Copyright © 2016 z0s. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(id: NSNumber, url: String,  context : NSManagedObjectContext) {
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entityForName("Photo",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.id = id
            self.url = url
        } else{
            fatalError("Unable to find Entity name!")
        }
        
    }

}
