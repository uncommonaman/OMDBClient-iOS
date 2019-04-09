//
//  Animator.swift
//  OMDBClient
//
//  Created by Amandeep on 08/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import Foundation
import UIKit

class  Animator: NSObject,UIViewControllerAnimatedTransitioning {
    var isPresenting = false
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            showPushAnimation(transitionContext: transitionContext)
        }
            
        else {
            showPopAnimation(transitionContext: transitionContext)
        }
        
        
    }
    
    private func imageViewForCell(vc:MasterViewController) -> UIImageView {
        let selected = vc.collectionView.indexPathsForSelectedItems?.first
        let cell = vc.collectionView.cellForItem(at: selected!) as! MediaCell
        return cell.posterImageView
        
    }
    
    
    
    func showPushAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! MasterViewController
        let toVC = transitionContext.viewController(forKey: .to) as! DetailViewController
        
        let container = transitionContext.containerView
        
        toVC.view.alpha = 0
        
        toVC.view.setNeedsLayout()
        toVC.view.layoutIfNeeded()
        
        
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        var frame = finalFrame
        frame.origin.y += frame.height
        toVC.view.frame = frame
        container.addSubview(toVC.view)
        toVC.view.backgroundColor = .clear
        
        let backDropView = UIView(frame: finalFrame)
        backDropView.backgroundColor = .black
        backDropView.alpha = 0
        container.insertSubview(backDropView, belowSubview: toVC.view)
        
        
        let fromImageView = imageViewForCell(vc: fromVC)
        let toImageView   = toVC.posterImageView!
        fromImageView.isHidden = true
      //  toImageView.isHidden = true
        toImageView.alpha = 0
        
        let snapshot =  fromImageView.snapshotView(afterScreenUpdates: false)!
        
        
        snapshot.frame = container.convert(snapshot.frame, from: fromImageView)
        container.addSubview(snapshot)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.view.alpha = 1
            toVC.view.frame = finalFrame
            backDropView.alpha = 1
            
            
            snapshot.frame =  container.convert(toImageView.frame, from: toImageView)
            
        }) { finished in
            backDropView.removeFromSuperview()
            toVC.view.backgroundColor = .black
            toImageView.isHidden = false
            toImageView.alpha = 1
            fromImageView.isHidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
            
        }
        
        
    }
    
    func showPopAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as! DetailViewController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as! MasterViewController
        
        let container = transitionContext.containerView
        
        toVC.view.setNeedsLayout()
        toVC.view.layoutIfNeeded()
        
        let fromImageView = fromVC.posterImageView!
        let toImageView = self.imageViewForCell(vc: toVC)
        
        let snapshot = fromImageView.snapshotView(afterScreenUpdates: false)!
       // fromImageView.isHidden = true
        fromImageView.alpha = 0
        toImageView.isHidden = true
        
        let backdrop = UIView(frame: fromVC.view.frame)
        backdrop.backgroundColor = .black
       container.insertSubview(backdrop, belowSubview: fromVC.view)
      // container.addSubview(backdrop)
        backdrop.alpha = 1
        fromVC.view.backgroundColor = UIColor.clear
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalFrame
        
        var frame = finalFrame
        frame.origin.y += frame.size.height
        container.insertSubview(toVC.view, belowSubview: backdrop)
        
        snapshot.frame = container.convert(fromImageView.frame, from: fromImageView)
        let ff = container.convert(toImageView.frame, from: toImageView)
        container.addSubview(snapshot)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            backdrop.alpha = 0
            fromVC.view.frame = frame
            snapshot.frame = ff
        }) { finished in
            fromVC.view.backgroundColor = backdrop.backgroundColor
           backdrop.removeFromSuperview()

            //fromImageView.isHidden = false
            fromImageView.alpha = 1
            toImageView.isHidden = false
            snapshot.removeFromSuperview()
            
            transitionContext.completeTransition(finished)
            
        }
  
    }
}
