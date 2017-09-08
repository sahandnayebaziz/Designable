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
                selection.forEach { s in
                    s.layer.borderWidth = 3
                    s.layer.borderColor = view.tintColor.cgColor
                }
            } else {
                view.subviews.forEach { s in
                    s.layer.borderWidth = 0
                }
            }
        }
    }
    
    var selectionPreGestureDescription: DesignablePreGestureDescription? = nil
    var activeGestureRecognizers: Set<UIGestureRecognizer> = []
    let gestureUndoManager = UndoManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(did(doubleTap:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        let twoFingerDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(did(twoFingerDoubleTap:)))
        twoFingerDoubleTapRecognizer.numberOfTouchesRequired = 2
        twoFingerDoubleTapRecognizer.numberOfTapsRequired = 2
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(did(pan:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(did(pinch:)))
        
        [doubleTapGestureRecognizer, twoFingerDoubleTapRecognizer, panGestureRecognizer, pinchGestureRecognizer].forEach { gestureRecognizer in
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
            guard pinch.numberOfTouches == 2, let selection = selection else {
                return
            }
            
            let touchOne = pinch.location(ofTouch: 0, in: view)
            let touchTwo = pinch.location(ofTouch: 1, in: view)
            
            
            let leftMostTouch = touchOne.x < touchTwo.x ? touchOne : touchTwo
            let rightMostTouch = leftMostTouch == touchOne ? touchTwo : touchOne
            
            let directionHint: PinchDirectionHint
            
            let radians = Float(atan2((leftMostTouch.y - rightMostTouch.y), (leftMostTouch.x - rightMostTouch.x)))
            let degrees = abs(radians * 57)
            
            let distanceFromHorizontal = abs(180 - degrees)
            let distanceFromDiagonal = abs(135 - degrees)
            let distanceFromVertical = abs(90 - degrees)
            let closest = min(distanceFromHorizontal, distanceFromDiagonal, distanceFromVertical)
            
            switch closest {
            case distanceFromHorizontal:
                directionHint = .horizontal
            case distanceFromDiagonal:
                directionHint = .diagonal
            case distanceFromVertical:
                directionHint = .vertical
            default:
                fatalError()
            }
            
            let selected = selection.first!
            
            let centerToMaintain = selected.center
            
            selected.frame = selection.first!.frame.applying(CGAffineTransform(scaleX: directionHint == .diagonal || directionHint == .horizontal ? pinch.scale : 1, y: directionHint == .diagonal || directionHint == .vertical ? pinch.scale : 1))
            selected.center = centerToMaintain
            pinch.scale = 1.0
        case .cancelled,
             .ended,
             .failed:
            gestureDidEnd(recognizer: pinch)
        default:
            break
        }
    }
    
    @objc func did(twoFingerDoubleTap: UITapGestureRecognizer) {
        gestureUndoManager.undo()
    }
    
    func gestureDidBegin(withIntersections intersections: [UIView], from recognizer: UIGestureRecognizer) {
        if activeGestureRecognizers.isEmpty {
            selection = intersections as? [DesignableUIView]
            let firstElementInSelection = selection!.first!
            let preGestureDescription = DesignablePreGestureDescription(center: firstElementInSelection.center, width: firstElementInSelection.frame.width, height: firstElementInSelection.frame.height)
            selectionPreGestureDescription = preGestureDescription
            
            gestureUndoManager.registerUndo(withTarget: self) { designVC in
                firstElementInSelection.frame = CGRect(x: 0, y: 0, width: preGestureDescription.width, height: preGestureDescription.height)
                firstElementInSelection.center = preGestureDescription.center
            }
            
            gestureUndoManager.setActionName("actions.reset-selection")
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
        newElement.alpha = 0.75
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

enum PinchDirectionHint {
    case vertical, horizontal, diagonal
}

