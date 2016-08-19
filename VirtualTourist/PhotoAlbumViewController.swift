//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by IT on 8/10/16.
//  Copyright © 2016 z0s. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let stack = (UIApplication.sharedApplication().delegate as! AppDelegate).stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsMultipleSelection = true
        
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let centeredRegion = MKCoordinateRegion(center: pin.coordinate, span: span)
        mapView.zoomEnabled = false;
        mapView.scrollEnabled = false;
        mapView.userInteractionEnabled = false;
        mapView.setRegion(centeredRegion, animated: true)
        let annotation = PinAnnotation()
        annotation.pin = pin
        annotation.coordinate = pin.coordinate
        mapView.addAnnotation(annotation)
        
        if let photos = pin.photos?.allObjects as? [Photo] {
            for photo in photos {
                FlickrAPI.requestImageAtURL(NSURL(string: photo.url!)!, completion: { (image, error) in
                    if let image = image {
                        photo.imageData = UIImagePNGRepresentation(image)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.stack.saveContext()
                            self.collectionView.reloadData()
                        })
                    }
                })
            }
        }
        
        newCollection.target = self
        newCollection.action = #selector(newCollectionButtonTapped)
    }
    
    var pin: Pin!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollection: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Collection view functions
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FlickrImageCell
        let photo = pin.photos?.allObjects[indexPath.row] as! Photo
        if let photoImageData = photo.imageData {
            cell.imageView.image = UIImage(data: photoImageData)
        } else {
            // no image data, need to download from web
            cell.setLoading(true)
            FlickrAPI.requestImageAtURL(NSURL(string: photo.url!)!, completion: { (image, error) in
                if let image = image {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let visibleCell = collectionView.cellForItemAtIndexPath(indexPath) as? FlickrImageCell {
                            visibleCell.setLoading(false)
                            visibleCell.imageView.image = image
                            visibleCell.layoutIfNeeded()
                        }
                        photo.imageData = UIImagePNGRepresentation(image)
                        
                        self.stack.saveContext()
                    })
                }
            })
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos!.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FlickrImageCell {
            if cell.selected {
                // cell is selected
                newCollection.title = "Remove Selected Images"
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // cell is deselected
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems() where selectedIndexPaths.count > 0 else {
            newCollection.title = "New Collection"
            return
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if cell.selected {
            cell.selected = true
        } else {
            cell.selected = false
        }
    }
    
    
    func newCollectionButtonTapped() {
        if newCollection.title == "New Collection" {
            pin.currentPage += 1
            let fetchRequest = NSFetchRequest(entityName: "Photo")
            fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try stack.context.executeRequest(deleteRequest)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            pin.photos = []
            
            stack.saveContext()

            
            FlickrAPI.requestImagesAtPin(pin, completion: { (results, error) in
                
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView.reloadData()
                        
                    })
                
            })
        }
        else if newCollection.title == "Remove Selected Images" {
            guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems() where selectedIndexPaths.count > 0 else {
                return
            }
            
            
            collectionView.performBatchUpdates({
                
                for indexPath in selectedIndexPaths {
                    let photo = self.pin.photos?.allObjects[indexPath.row] as! Photo
                    self.stack.context.deleteObject(photo)
                }
                self.stack.saveContext()
                self.collectionView.deleteItemsAtIndexPaths(selectedIndexPaths)
                
                }, completion: { (finished) in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.newCollection.title = "New Collection"
                        
                    })
            })
        }
        
    }
}
