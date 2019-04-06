//
//  MediaCell.swift
//  OMDBClient
//
//  Created by Amandeep on 02/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import UIKit

class MediaCell: UICollectionViewCell {
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var mediaTypeImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    
    override func prepareForReuse() {
       posterImageView.image = nil
        mediaTypeImageView.image = nil
        titleLabel.text = nil
        releaseDateLabel.text = nil
    }
    
}

