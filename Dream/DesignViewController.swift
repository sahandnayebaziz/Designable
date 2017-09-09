//
//  DesignViewController.swift
//  Dream
//
//  Created by Sahand on 9/7/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class DesignViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var selection: [UIView]? = nil {
        didSet {
            if let selection = selection {
                selection.forEach { v in
                    v.layer.borderWidth = 3
                    v.layer.borderColor = view.tintColor.cgColor
                }
            } else {
                view.subviews.forEach { v in
                    v.layer.borderWidth = 0
                }
            }
        }
    }
    
    var activeGestureRecognizers: Set<UIGestureRecognizer> = []
    let designUndoManager = UndoManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(did(doubleTap:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        let twoFingerDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(did(twoFingerDoubleTap:)))
        twoFingerDoubleTapRecognizer.numberOfTouchesRequired = 2
        twoFingerDoubleTapRecognizer.numberOfTapsRequired = 2
        
        let threeFingerDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(did(threeFingerDoubleTap:)))
        threeFingerDoubleTapRecognizer.numberOfTouchesRequired = 3
        threeFingerDoubleTapRecognizer.numberOfTapsRequired = 2
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(did(pan:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(did(pinch:)))
        
        [doubleTapGestureRecognizer, twoFingerDoubleTapRecognizer, threeFingerDoubleTapRecognizer, panGestureRecognizer, pinchGestureRecognizer].forEach { gestureRecognizer in
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
            
            gestureDidBegin(withViews: intersections as! [UIViewDesignable], from: pan)
        case .changed:
            guard let selection = selection as? [UIViewDesignable] else {
                return
            }
            
            let translation = pan.translation(in: view)
            
            let firstElement = selection.first as! UIView
            firstElement.frame = firstElement.frame.applying(CGAffineTransform(translationX: translation.x, y: translation.y))
            pan.setTranslation(.zero, in: view)
        case .cancelled,
             .ended,
             .failed:
            
            if let selection = selection as? [UIViewDesignable] {
                let velocity = pan.velocity(in: view)
                if abs(velocity.x) > 2000 || abs(velocity.y) > 2000 {
                    remove(elements: selection)
                }
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
            
            gestureDidBegin(withViews: intersections as! [UIViewDesignable], from: pinch)
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
        designUndoManager.undo()
    }
    
    @objc func did(threeFingerDoubleTap: UITapGestureRecognizer) {
        designUndoManager.redo()
    }
    
    func gestureDidBegin(withViews views: [UIViewDesignable], from recognizer: UIGestureRecognizer) {
        if activeGestureRecognizers.isEmpty {
            selection = views as? [UIView]
            
            let firstElement = selection!.first!
            let pre = DesignablePreGestureDescription(center: firstElement.center, width: firstElement.frame.width, height: firstElement.frame.height)
            (firstElement as! UIViewDesignable).preGesturePositionDescription = pre
            
            designUndoManager.registerUndo(withTarget: self) { _ in
                let currentFrame = firstElement.frame
                
                firstElement.frame = CGRect(x: 0, y: 0, width: pre.width, height: pre.height)
                firstElement.center = pre.center
                
                self.designUndoManager.registerUndo(withTarget: self) { _ in
                    firstElement.frame = currentFrame
                }
            }
            
            designUndoManager.setActionName("actions.reset-selection")
        }
        
        activeGestureRecognizers.insert(recognizer)
    }
    
    func gestureDidEnd(recognizer: UIGestureRecognizer) {
        activeGestureRecognizers.remove(recognizer)
        
        if activeGestureRecognizers.isEmpty {
            selection = nil
        }
    }
    
    func remove(elements: [UIViewDesignable]) {
        let descriptions: [DesignableDescription] = elements.map { $0.designableDescription }
        
        designUndoManager.registerUndo(withTarget: self) { _ in
            let restoredElements = self.restore(descriptions: descriptions)
            self.designUndoManager.registerUndo(withTarget: self) { _ in
                self.remove(elements: restoredElements)
            }
        }
        
        (elements as! [UIView]).forEach { $0.removeFromSuperview() }
    }
    
    func restore(descriptions: [DesignableDescription]) -> [UIViewDesignable] {
        let elements = descriptions.map { $0.toUIViewDesignable() }
        for i in 0..<elements.count {
            let element = elements[i] as! UIView
            let description = descriptions[i]
            
            view.addSubview(element)
            element.frame = CGRect(x: description.x, y: description.y, width: description.width, height: description.height)
        }
        
        return elements
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func did(doubleTap: UITapGestureRecognizer) {
        let point = doubleTap.location(in: view)
        
        let newElement = DesignableUIViewRectangle()
        view.addSubview(newElement)
        newElement.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        newElement.center = point
        
        designUndoManager.registerUndo(withTarget: self) { vc in
            vc.remove(elements: [newElement])
        }
    }
}

struct DesignablePreGestureDescription {
    let center: CGPoint
    let width: CGFloat
    let height: CGFloat
}

class DesignableUIViewRectangle: UIView, UIViewDesignable {
    
    var preGesturePositionDescription: DesignablePreGestureDescription? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        alpha = 0.75
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var designableDescription: DesignableDescription {
        let isInActiveGesture = preGesturePositionDescription != nil
        
        if isInActiveGesture {
            let pre = preGesturePositionDescription!
            let desc =  DesignableDescription(type: .rectangle, x: pre.center.x - (pre.width / 2), y: pre.center.y - (pre.height / 2), width: pre.width, height: pre.height)
            return desc
        } else {
            return DesignableDescription(type: .rectangle, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        }
    }
}

enum PinchDirectionHint {
    case vertical, horizontal, diagonal
}

