//
//  ViewController.swift
//  OMDBClient
//
//  Created by Amandeep on 01/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    let defaultSession = URLSession(configuration: .default)
    var apiClient: OMDBClient!
    
    //MARK:-View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCellSizing()
        
        apiClient = OMDBClient(session: defaultSession, delegate: self)
        fetchData()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCellSizing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    
  
    
    //MARK:- Networking
    func fetchData() {
        apiClient.fetchSearchResults(completion: { result in
            switch result {
            case .success(_):
                self.collectionView.reloadData()
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                })
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    
    
    //MARK:- Setup UI
    private func setupNavigationBar() {
        self.navigationItem.title = "Batman"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCellSizing()  {
        let layout = collectionView.collectionViewLayout as!  UICollectionViewFlowLayout
        let width = self.view.frame.width - (self.view.safeAreaInsets.left * 2)
        let coloumns:CGFloat = 2
        let size = (width - 10 - 20) / coloumns
        layout.itemSize = CGSize(width: size, height: size)
        
    }
}


//MARK:- Collection view Datasource & Delegate
extension MasterViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apiClient.total
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        
        if indexPath.row < apiClient.content!.count {
            
            let item = apiClient.content![indexPath.row]
            
            cell.mediaTypeImageView.image = UIImage(named: item.type.rawValue)
            cell.releaseDateLabel.text = item.formattedDate
            //cell.releaseDateLabel.text = "Page: \(apiClient.currentPage) Index: \(indexPath.row)"
            cell.titleLabel.text = item.title
            
            if let img = ImageDownloadManager.cache.object(forKey: item.poster as NSString) {
                print("Found cached for index: \(indexPath.row) Title: \(cell.titleLabel.text ?? "")")
                cell.posterImageView.image = img
            }
                
            else {
                let downloadManager = ImageDownloadManager()
                
                cell.activityIndicatorView.startAnimating()
                downloadManager.downloadImage(item: item, indexPath: indexPath) { img in
                    print("Handler called for index: \(indexPath.row) Title: \(cell.titleLabel.text ?? ""))")
                    
                    
                    //Check if cell is not reused
                    if collectionView.indexPath(for: cell)?.row == indexPath.row {
                        print("✅ Row matched for index: \(indexPath.row) Title: \(cell.titleLabel.text ?? ""))")
                        cell.activityIndicatorView.stopAnimating()
                        cell.posterImageView.image = img
                    }
                    // If cell is not preloaded cell i.e created but not visible
                    else {
                        if let updatedCell = collectionView.cellForItem(at: indexPath) as? MediaCell {
                            updatedCell.activityIndicatorView.stopAnimating()
                            updatedCell.posterImageView.image = img
                        }
                        print("❌ index: \(indexPath.row) collection index: \(collectionView.indexPath(for: cell)?.row ?? 0)")
                    }
                }
                
            }
            
        }
        else {
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //Uncomment for agressive canceling
     //  ImageDownloadManager.cancelOperation(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //Preloaded cell that are displayed later
        if let mediaCell = cell as? MediaCell {
            if indexPath.row < apiClient.content!.count {
                let item = apiClient.content![indexPath.row]
                if let img = ImageDownloadManager.cache.object(forKey: item.poster as NSString) {
                     mediaCell.activityIndicatorView.stopAnimating()

                    mediaCell.posterImageView.image = img
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        if let item = apiClient.content?[indexPath.row] {
            if let image = ImageDownloadManager.cache.object(forKey: item.poster as NSString) {
                vc.posterImage = image
            }
            vc.titleText = item.title
            vc.typeAndYear = "(\(item.type.rawValue.capitalized) \(item.year))"
        }
       self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK:- CollectionView Prefetching
extension MasterViewController: UICollectionViewDataSourcePrefetching {
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
        for indexPath in indexPaths {
            print("Will cancel pending operation at: \(indexPath)")
            ImageDownloadManager.cancelOperation(indexPath: indexPath)

        }
        
    }
    
}

//MARK:- Pagination Delegate
extension MasterViewController: PaginationDelegate {
    func didAddPage(indexPaths: [IndexPath]) {
        let visibleIndexPaths = Set(self.collectionView.indexPathsForVisibleItems)
        let indexPathsNeedingReload = Set(indexPaths).intersection(visibleIndexPaths)
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: Array(indexPathsNeedingReload))
        }, completion: nil)
    }
    
    func didFailFetchingNextPage(error: ApiError, pageNumber: Int) {
        let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { action -> Void in
            // Put your code here
        })
        
        self.present(alert, animated: true, completion: nil)
        
    }
}


//MARK:- Navigation Controller delegate for transition animation
extension MasterViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
      if  UIApplication.shared.statusBarOrientation.isPortrait   {
            if operation == .push {
                let animator = Animator()
                animator.isPresenting = true
                return animator
            }
            else {
                return  nil
            }
        }
         else {
            return nil
        }
      
    }
}
