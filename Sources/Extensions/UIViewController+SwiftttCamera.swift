// Copyright © 2021 Roger Oba. All rights reserved.

import UIKit

public extension UIViewController {

    /// Adds as a child view controller of this view controller below the given sibling subview and handles view appearance transition event calls.
    /// - Parameters:
    ///   - childViewController: The child view controller to add.
    ///   - containerView: An optional container view that will hold the child view controller's view. Defaults to the hosting view controller's main view.
    ///   - siblingSubview: The subview below which to add the child view controller's view.
    func swiftttAddChild(_ childViewController: UIViewController, inContainer containerView: UIView? = nil, belowSubview siblingSubview: UIView? = nil) {
        let view: UIView = containerView ?? self.view
        childViewController.beginAppearanceTransition(true, animated: false)
        addChild(childViewController)
        if let siblingSubview = siblingSubview, view.subviews.contains(siblingSubview) {
            view.insertSubview(childViewController.view, belowSubview: siblingSubview)
        } else {
            view.addSubview(childViewController.view)
        }
        childViewController.didMove(toParent: self)
        childViewController.endAppearanceTransition()
    }

    /// Removes the given child view controller from this view controller and handles view appearance transition event calls.
    /// - Parameter childViewController: The child view controller to remove.
    func swiftttRemoveChild(_ childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.beginAppearanceTransition(false, animated: false)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
        childViewController.endAppearanceTransition()
    }
}
