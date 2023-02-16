//
//  CalendarPresentationController.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/04.
//

import UIKit

final class CalendarPresentationController: UIPresentationController {
    private var originalPosition: CGPoint?
    private var currentPositionTouched: CGPoint?
    private let dimmingView: UIView = {
        let dimmingView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemMaterialDark)
        )
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        return dimmingView
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let screenBounds = UIScreen.main.bounds
        let size = CGSize(width: screenBounds.width * 0.75,
                          height: screenBounds.height * 0.25)
        let origin = CGPoint(x: screenBounds.width * 0.25,
                             y: screenBounds.height * 0.25 * 0.25)
        
        return CGRect(origin: origin, size: size)
    }
    
    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)

        presentedView?.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin
        ]

        presentedView?.translatesAutoresizingMaskIntoConstraints = true
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let superview = presentingViewController.view else { return }
        superview.addSubview(dimmingView)
        setupDimmingViewLayout(in: superview)
        adoptTapGestureRecognizer()
        dimmingView.alpha = 0
        presentingViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
            self.dimmingView.alpha = 0.5
        })
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentingViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }

    private func adoptTapGestureRecognizer() {
        guard let adoptedView = containerView else { return }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(dismissView(_:)))
        adoptedView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupDimmingViewLayout(in view: UIView) {
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    @objc private func dismissView(_ sender: UITouch) {
        let point = sender.location(in: presentedView)
        let size = UIScreen.main.bounds.height
        
        if point.y > size * 0.25 || point.x < 0 {
            presentedViewController.dismiss(animated: true)
        }
    }
}
