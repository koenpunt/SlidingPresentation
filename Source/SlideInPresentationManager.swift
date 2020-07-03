//  Copyright © 2018 Koen Punt. All rights reserved.
//
// Simple presentation controller for "sliding" view controller presentations.
// The `preferredContentSize` of the presented view controller controls the
// size of the presented view controller.
// Updating `preferredContentSize` when the view controller is presented is
// also possible.

import UIKit

// MARK: - SlidingPresentationManager

public class SlidingPresentationManager: NSObject {
    public enum SlideDirection {
        case fromLeft, fromRight, fromTop, fromBottom
    }
    
    /// The direction of the transition, defaults to `.fromBottom`.
    public var direction: SlideDirection = .fromBottom

    public init(direction: SlideDirection = .fromBottom) {
        self.direction = direction
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension SlidingPresentationManager: UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        SlidingPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            direction: direction
        )
    }

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SlidingPresentationAnimator(direction: direction, isPresentation: true)
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SlidingPresentationAnimator(direction: direction, isPresentation: false)
    }
}

// MARK: - SlidingPresentationController

private class SlidingPresentationController: UIPresentationController {
    typealias PresentationDirection = SlidingPresentationManager.SlideDirection
    
    lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        dimmingView.alpha = 0

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimmingView.addGestureRecognizer(recognizer)
        return dimmingView
    }()

    var direction: PresentationDirection

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         direction: PresentationDirection) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            containerView.insertSubview(dimmingView, at: 0)
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dimmingView.frame = containerView.bounds
        }

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }

        coordinator.animate(alongsideTransition: { [dimmingView] _ in
            dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }

        coordinator.animate(alongsideTransition: { [dimmingView] _ in
            dimmingView.alpha = 0
        })
    }

    override func preferredContentSizeDidChange(
        forChildContentContainer container: UIContentContainer
    ) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        guard let containerView = containerView else {
            return
        }

        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        let preferredContentSize = container.preferredContentSize
        return CGSize(
            width: min(parentSize.width, preferredContentSize.width),
            height: min(parentSize.height, preferredContentSize.height)
        )
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)
        switch direction {
        case .fromRight:
            frame.origin.x = containerView!.frame.width - frame.size.width
        case .fromBottom:
            frame.origin.y = containerView!.frame.height - frame.size.height
        default:
            frame.origin = .zero
        }
        return frame
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
}

// MARK: - SlidingPresentationAnimator

private class SlidingPresentationAnimator: NSObject {
    typealias PresentationDirection = SlidingPresentationManager.SlideDirection
    
    let direction: PresentationDirection
    let isPresentation: Bool

    init(direction: PresentationDirection, isPresentation: Bool) {
        self.direction = direction
        self.isPresentation = isPresentation
        super.init()
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension SlidingPresentationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
        let controller = transitionContext.viewController(forKey: key)!

        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }

        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame

        switch direction {
        case .fromLeft:
            dismissedFrame.origin.x = -presentedFrame.width
        case .fromRight:
            dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
        case .fromTop:
            dismissedFrame.origin.y = -presentedFrame.height
        case .fromBottom:
            dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
        }

        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame

        UIView.animate(withDuration: animationDuration, animations: {
            controller.view.frame = finalFrame
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
