//
//  ImageManager.swift
//  OMDBClient
//
//  Created by Amandeep on 05/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import Foundation
import UIKit

typealias ImageDownloadHandler = (_ image:UIImage) -> Void
final class ImageDownloadManager {
//     private static var pendingOperations:[IndexPath:ImageDownloader] = [:]
    private static var pendingOperations = SynchronizedDictionary<IndexPath,ImageDownloader>()
     static var cache =  NSCache<NSString,UIImage>()
    lazy var queue: OperationQueue = {
        let q = OperationQueue()
        q.name = "imageDownloaderQueue"
     //    q.maxConcurrentOperationCount = 1
        return q
    }()
    
    
    
    private var completionHandler:ImageDownloadHandler?
    
    func downloadImage(item:Result, indexPath:IndexPath, handler: @escaping ImageDownloadHandler) {
        self.completionHandler = handler
        
        if let cachedImage = ImageDownloadManager.cache.object(forKey: item.poster as NSString) {
            print("Returning cached image for URL: \(item.poster) and row: \(indexPath.row)")
            DispatchQueue.main.async {
                self.completionHandler?(cachedImage)
            }
        }
            else {
//                if let pendingOperation = ImageDownloadManager.pendingOperations[indexPath] {
             if let pendingOperation = ImageDownloadManager.pendingOperations.valueFor(key: indexPath) {
                    print("Operation is already pending for URL: \(item.poster) and row: \(indexPath.row)")
                    pendingOperation.queuePriority = .high
                 
                    return
                } else {
                    print("Creating a new task to download the image")
                    let operation = ImageDownloader(photoRecord: item)
                   operation.queuePriority = .veryHigh
                    operation.completionBlock = {
                        if operation.isCancelled {
                            return
                        }
                        ImageDownloadManager.pendingOperations.removeValue(key: indexPath)
                        
                        if operation.isCancelled {
                            return
                        }
                        ImageDownloadManager.cache.setObject(operation.image, forKey: item.poster as NSString)
                        if operation.isCancelled {
                            return
                        }
                        DispatchQueue.main.async {
                            self.completionHandler?(operation.image)
                        }
                    }
                ImageDownloadManager.pendingOperations.add(value: operation, key: indexPath)
                    queue.addOperation(operation)
                    
                    
                }
            }
            
        }
    
  static func  cancelOperation(indexPath:IndexPath)  {
     if let pendingOperation = ImageDownloadManager.pendingOperations.valueFor(key: indexPath) {
        
        pendingOperation.queuePriority = .low
            print("Did cancel pending operation at: \(indexPath)")
        // pendingOperation.cancel()
       // ImageDownloadManager.pendingOperations.removeValue(key: indexPath)
        }
    }
        
        
}
