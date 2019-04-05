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
    private var pageNumber = 1
    private var isFetching = false
    let defaultSession = URLSession(configuration: .default)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Batman"
       navigationController?.navigationBar.prefersLargeTitles = true
       setupCellSizing()
        fetchData()
        
       
    }
    
    private func setupCellSizing() {
        let layout = collectionView.collectionViewLayout as!  UICollectionViewFlowLayout
        let width = self.view.frame.width
        let coloumns:CGFloat = 2
        let size = (width - 10 - 20) / coloumns
        layout.itemSize = CGSize(width: size, height: size)
    }
    
    private func incrementalFetch(){
        if self.content!.search.count < Int(self.content!.totalResults)! {
            fetchData()
        }
    }
    
    private func fetchData() {
      
        let path = "http://www.omdbapi.com/?s=Batman&page=\(pageNumber)&apikey=eeefc96f"
        let url  = URL(string: path)!
        isFetching = true
        defaultSession.dataTask(with: url) { data, response, error in
            self.isFetching = false
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
                guard decodedResponse.search.count > 0 else {
                    print("No data found")
                    return
                }
                DispatchQueue.main.async {
                  
                    if let content = self.content {
                        self.pageNumber = self.pageNumber + 1
                        let startIndex = self.content!.search.count
                        self.content?.search.append(contentsOf: decodedResponse.search)
                        let endIndex = self.content!.search.count - 1
                        
                        //  self.collectionView.reloadData()
                        var paths = [IndexPath]()
                        for i in startIndex...endIndex {
                            paths.append(IndexPath(item: i, section: 0))
                        }
                        self.collectionView.performBatchUpdates({
                            self.collectionView.reloadItems(at: paths)
                        }, completion: nil)
                        

                    }
                    else {
                         self.pageNumber = self.pageNumber + 1
                        self.content = decodedResponse
                         self.collectionView.reloadData()
                    }
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
        if indexPath.row < content!.search.count {
            let item = content!.search[indexPath.row]
            cell.mediaTypeImageView.image = UIImage(named: item.type.rawValue)
            cell.releaseDateLabel.text = item.year
            cell.titleLabel.text = item.title
            cell.backgroundColor = .white
            downloadImage(path: item.poster, handler: { img in
                cell.posterImageView.image = UIImage(data: img)
                
            })
            //  cell.backgroundView?.backgroundColor = .black
            //  cell.backgroundColor = .black
            
            
        }
        else {
                cell.backgroundColor = .black
        }
      
        return cell
    }
    
    
    private func downloadImage(path:String,handler: @escaping (_ image:Data) -> Void) {
        DispatchQueue.global().async {
            let url = URL(string: path)
            do {
                let data = try Data(contentsOf: url!)
                DispatchQueue.main.async {
                    handler(data)
                }
            }
            catch {
                print("URL:\(url)")
                print("ERROR: \(error)")
            }
         
            
        }
    }
    
    
    
}


extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths)
        let arrayIndexs = content!.search.enumerated().map { offset, element in return IndexPath(row: offset, section: 0)}
        let contentSet = Set(arrayIndexs)
        for indexPath in indexPaths {
            if contentSet.contains(indexPath) && !isFetching {
                incrementalFetch()
            }
        }
//        let prefetchSet = Set(indexPaths)
//        let intersection = prefetchSet.intersection(contentSet)
//
//        if intersection.count < prefetchSet.count && !isFetching {
//            fetchData()
//        }
    }
    
    
}

