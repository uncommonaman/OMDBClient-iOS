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
    
    
    private func fetchData() {
        
        let path = "http://www.omdbapi.com/?s=Batman&page=7&apikey=eeefc96f"
        let url  = URL(string: path)!
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
                guard decodedResponse.search.count > 0 else {
                    print("No data found")
                    return
                }
                DispatchQueue.main.async {
                    self.content = decodedResponse
                    self.collectionView.reloadData()
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
        return content?.search.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        let item = content!.search[indexPath.row]
        cell.mediaTypeImageView.image = UIImage(named: item.type.rawValue)
        cell.releaseDateLabel.text = item.year
        cell.titleLabel.text = item.title
      
            downloadImage(path: item.poster, handler: { img in
                  cell.posterImageView.image = UIImage(data: img)
                
            })
      //  cell.backgroundView?.backgroundColor = .black
      //  cell.backgroundColor = .black
        
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
                
            }
         
            
        }
    }
    
    
    
}




