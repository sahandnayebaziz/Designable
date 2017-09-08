//
//  DesignViewController.swift
//  Dream
//
//  Created by Sahand on 9/7/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class DesignViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var selection: [DesignableUIView]? = nil {
        didSet {
            if let selection = selection {
                selection.forEach { $0.backgroundColor = view.tintColor }
            } else {
                view.subviews.forEach { $0.backgroundColor = .lightGray }
            }
        }
    }
    
    var selectionPreGestureDescription: DesignablePreGestureDescription? = nil
    var activeGestureRecognizers: Set<UIGestureRecognizer> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(did(doubleTap:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(did(pan:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(did(pinch:)))
        
        [doubleTapGestureRecognizer, panGestureRecognizer, pinchGestureRecognizer].forEach { gestureRecognizer in
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func did(pan: UIPanGestureRecognizer) {
        guard pan.numberOfTouches < 3 else {
            return
        }

        switch pan.state {
        case .began:
            var points: [CGPoint] = []
            for i in 0..<pan.numberOfTouches {
                points.append(pan.location(ofTouch: i, in: view))
            }
            
            let intersections = view.subviews.filter { subview in
                let pointsThatIntersectSubview = points.filter { subview.layer.contains(view.convert($0, to: subview)) }
                return pointsThatIntersectSubview.count == pan.numberOfTouches
            }
            
            guard !intersections.isEmpty else {
                return
            }
            
            gestureDidBegin(withIntersections: intersections, from: pan)
        case .changed:
            guard let selection = selection, let selectionPreGestureDescription = selectionPreGestureDescription else {
                return
            }
            
            let translation = pan.translation(in: view)
            selection.first!.center = selectionPreGestureDescription.center
            selection.first!.frame = selection.first!.frame.applying(CGAffineTransform(translationX: translation.x, y: translation.y))
        case .cancelled,
             .ended,
             .failed:
            
            let velocity = pan.velocity(in: view)
            if abs(velocity.x) > 2000 || abs(velocity.y) > 2000 {
                removeSelection()
            }
            
            gestureDidEnd(recognizer: pan)
        default:
            break
        }
    }
    
    @objc func did(pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            guard pinch.numberOfTouches == 2 else {
                fatalError("WTF?")
            }
            
            
            var points: [CGPoint] = []
            for i in 0..<pinch.numberOfTouches {
                points.append(pinch.location(ofTouch: i, in: view))
            }
            
            let intersections = view.subviews.filter { subview in
                let pointsThatIntersectSubview = points.filter { subview.layer.contains(view.convert($0, to: subview)) }
                return pointsThatIntersectSubview.count == pinch.numberOfTouches
            }
            
            guard !intersections.isEmpty else {
                return
            }
            
            gestureDidBegin(withIntersections: intersections, from: pinch)
        case .changed:
            guard let selection = selection, let selectionPreGestureDescription = selectionPreGestureDescription else {
                return
            }
            
            let selected = selection.first!
            
            let centerToMaintain: CGPoint
            
            let selectedHasChangedCenterDuringGesture = selected.center != selectionPreGestureDescription.center
            if (selectedHasChangedCenterDuringGesture) {
                centerToMaintain = selected.center
            } else {
                centerToMaintain = selectionPreGestureDescription.center
            }
            
            selected.frame = CGRect(x: 0, y: 0, width: selectionPreGestureDescription.width, height: selectionPreGestureDescription.height)
            selected.frame = selection.first!.frame.applying(CGAffineTransform(scaleX: pinch.scale, y: pinch.scale))
            selected.center = centerToMaintain
        case .cancelled,
             .ended,
             .failed:
            gestureDidEnd(recognizer: pinch)
        default:
            break
        }
    }
    
    func gestureDidBegin(withIntersections intersections: [UIView], from recognizer: UIGestureRecognizer) {
        if activeGestureRecognizers.isEmpty {
            selection = intersections as? [DesignableUIView]
            let firstElementInSelection = selection!.first!
            selectionPreGestureDescription = DesignablePreGestureDescription(center: firstElementInSelection.center, width: firstElementInSelection.frame.width, height: firstElementInSelection.frame.height)
        }
        
        activeGestureRecognizers.insert(recognizer)
    }
    
    func gestureDidEnd(recognizer: UIGestureRecognizer) {
        activeGestureRecognizers.remove(recognizer)
        
        if activeGestureRecognizers.isEmpty {
            selection = nil
            selectionPreGestureDescription = nil
        }
    }
    
    func removeSelection() {
        guard let selection = selection else {
            return
        }
        
        selection.forEach { $0.removeFromSuperview() }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func did(doubleTap: UITapGestureRecognizer) {
        let point = doubleTap.location(in: view)
        
        let newElement = DesignableUIView()
        newElement.backgroundColor = UIColor.lightGray
        view.addSubview(newElement)
        newElement.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        newElement.center = point
    }
}

struct DesignablePreGestureDescription {
    let center: CGPoint
    let width: CGFloat
    let height: CGFloat
}

class DesignableUIView: UIView {}

extension CGPoint {

    func centerBetweenSelf(andOtherPoint otherPoint: CGPoint) -> CGPoint {
        return CGPoint(x: (self.x + otherPoint.x) / 2, y: (self.y + otherPoint.y) / 2)
    }
}

// TODO: scale by Y, X, Both depending on slope of line? Angle of line?

