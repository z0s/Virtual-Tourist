//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by IT on 8/12/16.
//  Copyright © 2016 z0s. All rights reserved.
//

import UIKit
import CoreLocation

typealias FlickrRequestCompletionHandler = (results: [Photo], error: NSError?) -> Void

typealias FlickrImageRequestCompletionHandler = (image: UIImage?, error: NSError?) -> Void

struct FlickrAPI {
    // MARK: Flickr API
    
    static let session = NSURLSession.sharedSession()
    static func requestImagesAtPin(pin: Pin, completion: FlickrRequestCompletionHandler?) {
        
        let methodParameters = [FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
                                FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
                                FlickrParameterKeys.Latitude: "\(pin.coordinate.latitude)",
                                FlickrParameterKeys.Longitude: "\(pin.coordinate.longitude)",
                                FlickrParameterKeys.Radius: FlickrParameterValues.Radius,
                                FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
                                FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
                                FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
                                FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
                                FlickrParameterKeys.PerPage: FlickrParameterValues.PerPage,
                                FlickrParameterKeys.Page: "\(pin.currentPage)"]
        
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrResponseKeys.Status] as? String where stat == FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                return
            }
            
            var photos = [Photo]()
            
            for photoDictionary in photosArray {
                if let id = photoDictionary[FlickrResponseKeys.ID] as? String, idDouble = Double(id), photoURL = photoDictionary[FlickrResponseKeys.MediumURL] as? String {
                    let stack = (UIApplication.sharedApplication().delegate as! AppDelegate).stack
                    let idNumber = NSNumber(double: idDouble)
                    let photo = Photo(id: idNumber, url: photoURL, context: stack.context)
                    photo.pin = pin
                    photos.append(photo)
                }
            }
            
            if let completion = completion {
                completion(results: photos, error: nil)
            }
            
        }
        
        // start the task!
        task.resume()
    }
    
    static func requestImageAtURL(url: NSURL, completion: FlickrImageRequestCompletionHandler?) {
        let task = session.dataTaskWithURL(url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            if let response = response as? NSHTTPURLResponse {
                // handle server response status codes
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    print("Your request returned a status code other than 2xx!")
                    return
                }
                
                let image = UIImage(data: data)
                
                if let completion = completion {
                    completion(image: image, error: error)
                }
            }}
        
        task.resume()
    }
    
    // FIX: For Swift 3, variable parameters are being depreciated. Instead, create a copy of the parameter inside the function.
    
    private func displayImageFromFlickrBySearch(methodParameters: [String:AnyObject], withPageNumber: Int) {
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[FlickrParameterKeys.Page] = withPageNumber
        
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrResponseKeys.Status] as? String where stat ==
                FlickrResponseValues.OKStatus else {
                    displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                    return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                //   let photoTitle = photoDictionary[FlickrResponseKeys.Title] as? String
                
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard (photoDictionary[FlickrResponseKeys.MediumURL] as? String) != nil else {
                    displayError("Cannot find key '\(FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
            }
        }
        
        // start the task!
        task.resume()
    }
}
    // MARK: Helper for Creating a URL from Parameters
    
    func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        let components = NSURLComponents()
        
        components.scheme = FlickrAPI.Flickr.APIScheme
        components.host = FlickrAPI.Flickr.APIHost
        components.path = FlickrAPI.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let  queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.URL!
        
    }
    
    