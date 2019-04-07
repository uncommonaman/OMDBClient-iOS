//
//  ViewController.swift
//  OMDBClient
//
//  Created by Amandeep on 01/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    let defaultSession = URLSession(configuration: .default)
    var apiClient: OMDBClient!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Batman"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupCellSizing()
        
        apiClient = OMDBClient(session: defaultSession, delegate: self)
        fetchData()
    }
    
    func fetchData()  {
        apiClient.fetchSearchResults(completion: { result in
            switch result {
            case .success(_):
                self.collectionView.reloadData()
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    
    private func setupCellSizing()  {
        let layout = collectionView.collectionViewLayout as!  UICollectionViewFlowLayout
        let width = self.view.frame.width - (self.view.safeAreaInsets.left * 2)
        let coloumns:CGFloat = 2
        let size = (width - 10 - 20) / coloumns
        layout.itemSize = CGSize(width: size, height: size)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCellSizing()
        
    }
    
}



extension ViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apiClient.total
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        
        if indexPath.row < apiClient.content!.count {
            
            let item = apiClient.content![indexPath.row]
            
            cell.mediaTypeImageView.image = UIImage(named: item.type.rawValue)
            //            cell.releaseDateLabel.text = "\(item.year) Page: \(currentPage) Index: \(indexPath.row)"
            //            cell.releaseDateLabel.text = item.formattedDate
            cell.releaseDateLabel.text = "Page: \(apiClient.currentPage) Index: \(indexPath.row)"
            cell.titleLabel.text = item.title
            
            if let img = ImageDownloadManager.cache.object(forKey: item.poster as NSString) {
                print("Found cached for index: \(indexPath.row) Title: \(cell.titleLabel.text)")
                cell.posterImageView.image = img
            }
                
            else {
                let downloadManager = ImageDownloadManager()
                downloadManager.downloadImage(item: item, indexPath: indexPath) {img in
                    print("Handler called for index: \(indexPath.row) Title: \(cell.titleLabel.text))")
                    
                    
                    
                    if collectionView.indexPath(for: cell)?.row == indexPath.row {
                        print("✅ Row matched for index: \(indexPath.row) Title: \(cell.titleLabel.text))")
                        cell.posterImageView.image = img
                    }
                    else {
                        if let updatedCell = collectionView.cellForItem(at: indexPath) as? MediaCell {
                            updatedCell.posterImageView.image = img
                        }
                        print("❌ index: \(indexPath.row) collection index: \(collectionView.indexPath(for: cell)?.row)")
                    }
                }
                
            }
            
        }
        else {
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        ImageDownloadManager.cancelOperation(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let mediaCell = cell as? MediaCell {
            if indexPath.row < apiClient.content!.count {
                let item = apiClient.content![indexPath.row]
                
                if let img = ImageDownloadManager.cache.object(forKey: item.poster as NSString) {
                    
                    //  print("Found cached for index: \(indexPath.row) Title: \(cell.titleLabel.text)")
                    mediaCell.posterImageView.image = img
                }
            }
        }
    }
    
    
}


extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths)
        guard let result = apiClient.content?.count else { return }
        let needsFetch = indexPaths.contains { $0.row >= result}
        if needsFetch {
            apiClient.fetchNextPage()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // print("Cancel prfetching at: \(indexPaths)")
        //        for indexPath in indexPaths {
        //         //    print("Will cancel pending operation at: \(indexPath)")
        //            ImageDownloadManager.cancelOperation(indexPath: indexPath)
        //
        //        }
        
    }
    
}


extension ViewController: PaginationDelegate {
    func didAddPage(indexPaths: [IndexPath]) {
        let visibleIndexPaths = Set(self.collectionView.indexPathsForVisibleItems)
        let indexPathsNeedingReload = Set(indexPaths).intersection(visibleIndexPaths)
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: Array(indexPathsNeedingReload))
        }, completion: nil)
    }
    
    func didFailFetchingNextPage(error: ApiError, pageNumber: Int) {
        let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
    }
}
