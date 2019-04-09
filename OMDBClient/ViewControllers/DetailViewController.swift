//
//  DetailViewController.swift
//  OMDBClient
//
//  Created by Amandeep on 08/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var typeAndYearLabel: UILabel!
    var posterImage: UIImage?
    var titleText: String?
    var typeAndYear:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
//    navigationController?.navigationBar.prefersLargeTitles = false
        titleLabel.text = titleText
        typeAndYearLabel.text = typeAndYear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        edgesForExtendedLayout = .bottom
        self.navigationController?.delegate = self
           posterImageView.image = posterImage
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        if UIApplication.shared.statusBarOrientation.isPortrait {
            stackView.axis = .vertical
        }
        else {
            stackView.axis = .horizontal
        }
    }

}


extension DetailViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if  UIApplication.shared.statusBarOrientation.isPortrait {
            if operation == .pop {
                let animator = Animator()
                animator.isPresenting = false
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
