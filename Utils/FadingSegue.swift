//
//  FadingSegue.swift
//  ToothpickDemo (iOS)
//
//  Created by Youssef on 8/14/21.
//

import UIKit

class FadingSegue: UIStoryboardSegue {
    
    public static var animationSpeed:Float { return 0.5 }
    
    override func perform() {
        destination.transitioningDelegate = self
        super.perform()
    }
}

class FadingViewController: UIViewController {
    
}

extension FadingSegue: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadingInPresentAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadingOutPresentAnimator()
    }
    
}

extension FadingViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadingInPresentAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadingOutPresentAnimator()
    }
}

class FadingInPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(FadingSegue.animationSpeed)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        
        let destVC = transitionContext.viewController(forKey: .to)!
        let destView = transitionContext.view(forKey: .to)
        
        let bgView = BGView()
        bgView.backgroundColor = .clear
        
        if let destView = destView {
            transitionContext.containerView.addSubview(bgView)
            transitionContext.containerView.addSubview(destView)
        }
        
        destView?.frame = CGRect(x: 0, y: fromVC.view.frame.height, width: fromVC.view.frame.width, height: fromVC.view.frame.height)
        destView?.alpha = 0
        destView?.backgroundColor = .clear
        destView?.layoutIfNeeded()
        
        let duration = transitionDuration(using: transitionContext)
        let finalFrame = transitionContext.finalFrame(for: destVC)
        
        bgView.frame = finalFrame
        
        UIView.animate(withDuration: duration, animations: {
            destView?.frame = finalFrame
            destView?.alpha = 1
            bgView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            destView?.layoutIfNeeded()
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
    
}

class FadingOutPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(FadingSegue.animationSpeed)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        var bgView: UIView?
        for v in container.subviews {
            if v is BGView {
                bgView = v
            }
        }
        let fromView = transitionContext.view(forKey: .from)!
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.frame.origin.y += container.frame.height - fromView.frame.minY
            fromView.alpha = 0
            bgView?.backgroundColor = .clear
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
    
}

class BGView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
