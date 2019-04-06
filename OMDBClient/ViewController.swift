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
    
    private var content: OMDBModel?
    private var currentPage = 1
    private var isFetchingNextPage = false
    
    let defaultSession = URLSession(configuration: .default)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Batman"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupCellSizing()
        fetchMovies()
        
        
    }
    
    private func setupCellSizing()  {
        let layout = collectionView.collectionViewLayout as!  UICollectionViewFlowLayout
        let width = self.view.frame.width - (self.view.safeAreaInsets.left * 2)
        let coloumns:CGFloat = 2
        let size = (width - 10 - 20) / coloumns
        layout.itemSize = CGSize(width: size, height: size)
 
    }
    
    private func fetchNextPage(){
        guard !isFetchingNextPage else { return }
        currentPage += 1
        fetchMovies()
    }
    

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCellSizing()
    
    }
    
    

    
    private func fetchMovies() {
        
        let path = "http://www.omdbapi.com/?s=Batman&page=\(currentPage)&apikey=eeefc96f"
        let url  = URL(string: path)!
        isFetchingNextPage = true
        defaultSession.dataTask(with: url) { data, response, error in
            
            guard let response = response as? HTTPURLResponse,response.statusCode == 200 else{
                print("Status code: invalid")
                return
            }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("Invalid data")
                return
            }
            
            do{
                let decodedResponse = try JSONDecoder().decode(OMDBModel.self, from: data)
                guard decodedResponse.response == "True" else {
                    print("Invalid response")
                    return
                }
                guard decodedResponse.results.count > 0 else {
                    print("No data found")
                    return
                }
                DispatchQueue.main.async {
                    //
                    if let content = self.content {
                        
                        let startIndex = self.content!.results.count
                        self.content?.results.append(contentsOf: decodedResponse.results)
                        let endIndex = self.content!.results.count - 1
                        
                        
                        
                        let newIndexPaths = (startIndex...endIndex).map { i in
                            return IndexPath(row: i, section: 0)
                        }
                        let visibleIndexPaths = Set(self.collectionView.indexPathsForVisibleItems)
                        let indexPathsNeedingReload = Set(newIndexPaths).intersection(visibleIndexPaths)
                        self.collectionView.performBatchUpdates({
                            self.collectionView.reloadItems(at: Array(indexPathsNeedingReload))
                        }, completion: nil)
                        
                        
                    }
                    else {
                        self.content = decodedResponse
                        self.collectionView.reloadData()
                    }
                    self.isFetchingNextPage = false
                }
                
            }
            catch {
                print("Parsing error")
            }
            
            
            
            }.resume()
    }
    
    
}



extension ViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(content?.totalResults ?? "0") ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        if indexPath.row < content!.results.count {
            let item = content!.results[indexPath.row]
            cell.mediaTypeImageView.image = UIImage(named: item.type.rawValue)
//            cell.releaseDateLabel.text = "\(item.year) Page: \(currentPage) Index: \(indexPath.row)"
            cell.releaseDateLabel.text = item.formattedDate 
            cell.titleLabel.text = item.title
            //  cell.backgroundColor = .white
            
            //  updateImageForCell(cell, collectionView: collectionView, item: item, indexPath: indexPath)
            let downloadManager = ImageDownloadManager()
            downloadManager.downloadImage(item: item, indexPath: indexPath) {img in
                print("Handler called for index: \(indexPath.row)")
                print(cell.titleLabel.text)
                
                
                if let cellToUpdate = collectionView.cellForItem(at: indexPath) as? MediaCell {
                    cellToUpdate.posterImageView.image = img
                    
                }
                
                if let img = ImageDownloadManager.cache.object(forKey: item.poster as NSString) {
                    cell.posterImageView.image = img
                }
                
            }
            
            
        }
        else {
            
        }
        
        return cell
    }
    
    
}


extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths)
        
        let needsFetch = indexPaths.contains { $0.row >= self.content!.results.count }
        if needsFetch {
            fetchNextPage()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("Cancel prfetching at: \(indexPaths)")
    }
    
    
    
    
    
}




