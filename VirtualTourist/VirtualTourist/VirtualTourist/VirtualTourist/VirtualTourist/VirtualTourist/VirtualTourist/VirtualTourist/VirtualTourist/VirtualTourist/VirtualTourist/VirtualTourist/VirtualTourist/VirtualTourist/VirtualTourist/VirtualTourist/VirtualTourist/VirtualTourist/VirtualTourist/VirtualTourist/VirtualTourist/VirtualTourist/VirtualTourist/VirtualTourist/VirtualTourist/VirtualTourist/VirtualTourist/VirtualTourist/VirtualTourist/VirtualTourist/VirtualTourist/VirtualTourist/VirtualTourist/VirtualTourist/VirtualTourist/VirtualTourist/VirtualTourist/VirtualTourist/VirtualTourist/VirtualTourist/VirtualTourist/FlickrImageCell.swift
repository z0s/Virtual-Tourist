//
//  FlickrImageCell.swift
//  VirtualTourist
//
//  Created by IT on 8/14/16.
//  Copyright © 2016 z0s. All rights reserved.
//

import UIKit

class FlickrImageCell: UICollectionViewCell {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override var selected: Bool {
        didSet {
            if selected {
                self.alpha = 0.3
            } else {
                self.alpha = 1.0
            }
        }
    }
    
    func setLoading(loading: Bool) {
        spinner.hidden = !loading
        if loading {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}
