//
//  ImageDownloader.swift
//  OMDBClient
//
//  Created by Amandeep on 05/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import Foundation
import UIKit
class ImageDownloader: Operation {
    
    let photoRecord: Search
    var image: UIImage
    
    init(photoRecord: Search) {
        self.photoRecord = photoRecord
        self.image = UIImage(named: "failed")!
    }
    
    override func main() {
        if isCancelled {
            print("❌")
            return
        }

        guard let url = photoRecord.posterURL,let imageData = try? Data(contentsOf: url) else { return }
        
        if isCancelled {
            print("❌")
            return
        }
        
        self.image = UIImage(data: imageData)!
    }
    
}
