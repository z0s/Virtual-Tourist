//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by IT on 8/7/16.
//  Copyright © 2016 z0s. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let stack = CoreDataStack(modelName: "VirtualTouristModel")!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }


}

