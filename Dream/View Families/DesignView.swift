//
//  DesignView.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import SnapKit

protocol DesignViewDelegate: class {
    func didTap(designView: DesignView)
    func didLongPress(designView: DesignView, selection: [UIViewDesignable]?)
    func didClearSelection()
}

struct DesignablePreGestureDescription {
    let center: CGPoint
    let width: CGFloat
    let height: CGFloat
}

enum PinchDirectionHint {
    case vertical, horizontal, diagonal
}

class DesignView: UIView, UIGestureRecognizerDelegate {
    
    let elementsView = UIView()
    weak var delegate: DesignViewDelegate?
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        
        elementsView.frame = bounds
        addSubview(elementsView)
        elementsView.snp.makeConstraints { make in
            make.size.equalTo(self)
            make.center.equalTo(self)
        }
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(did(singleTap:)))
        
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
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(did(longPress:)))
        
        [singleTapGestureRecognizer, doubleTapGestureRecognizer, twoFingerDoubleTapRecognizer, threeFingerDoubleTapRecognizer, panGestureRecognizer, pinchGestureRecognizer, longPressGestureRecognizer].forEach { gestureRecognizer in
            gestureRecognizer.delegate = self
            addGestureRecognizer(gestureRecognizer)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var selection: [UIView]? = nil {
        didSet {
            if let selection = selection {
                elementsView.subviews.forEach { v in
                    v.layer.borderWidth = 0
                }
                selection.forEach { v in
                    v.layer.borderWidth = 3
                    v.layer.borderColor = tintColor.cgColor
                }
            } else {
                elementsView.subviews.forEach { v in
                    v.layer.borderWidth = 0
                }
                delegate?.didClearSelection()
            }
        }
    }
    
    var activeGestureRecognizers: Set<UIGestureRecognizer> = []
    let designUndoManager = UndoManager()
    
    @objc func did(singleTap: UITapGestureRecognizer) {
        delegate?.didTap(designView: self)
    }
    
    @objc func did(doubleTap: UITapGestureRecognizer) {
        let point = doubleTap.location(in: elementsView)
        
        let newElement = UIViewDesignableRectangleUIView()
        elementsView.addSubview(newElement)
        newElement.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        newElement.center = point
        
        designUndoManager.registerUndo(withTarget: self) { vc in
            vc.remove(elements: [newElement])
        }
    }
    
    @objc func did(twoFingerDoubleTap: UITapGestureRecognizer) {
        designUndoManager.undo()
    }
    
    @objc func did(threeFingerDoubleTap: UITapGestureRecognizer) {
        designUndoManager.redo()
    }
    
    @objc func did(pan: UIPanGestureRecognizer) {
        guard pan.numberOfTouches < 3 else {
            return
        }
        
        switch pan.state {
        case .began:
            var points: [CGPoint] = []
            for i in 0..<pan.numberOfTouches {
                points.append(pan.location(ofTouch: i, in: elementsView))
            }
            
            let intersections = elementsView.subviews.filter { subview in
                let pointsThatIntersectSubview = points.filter { subview.layer.contains(elementsView.convert($0, to: subview)) }
                return pointsThatIntersectSubview.count == pan.numberOfTouches
            }
            
            guard !intersections.isEmpty else {
                return
            }
            
            let topMostViewOnly = [intersections.last!]
            
            gestureDidBegin(withViews: topMostViewOnly as! [UIViewDesignable], from: pan)
        case .changed:
            guard let selection = selection as? [UIViewDesignable] else {
                return
            }
            
            let translation = pan.translation(in: elementsView)
            
            let firstElement = selection.first as! UIView
            firstElement.frame = firstElement.frame.applying(CGAffineTransform(translationX: translation.x, y: translation.y))
            pan.setTranslation(.zero, in: elementsView)
        case .cancelled,
             .ended,
             .failed:
            
            if let selection = selection as? [UIViewDesignable] {
                let velocity = pan.velocity(in: elementsView)
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
                points.append(pinch.location(ofTouch: i, in: elementsView))
            }
            
            let intersections = elementsView.subviews.filter { subview in
                let pointsThatIntersectSubview = points.filter { subview.layer.contains(elementsView.convert($0, to: subview)) }
                return pointsThatIntersectSubview.count == pinch.numberOfTouches
            }
            
            guard !intersections.isEmpty else {
                return
            }
            
            let topMostViewOnly = [intersections.last!]
            
            gestureDidBegin(withViews: topMostViewOnly as! [UIViewDesignable], from: pinch)
        case .changed:
            guard pinch.numberOfTouches == 2, let selection = selection else {
                return
            }
            
            let touchOne = pinch.location(ofTouch: 0, in: elementsView)
            let touchTwo = pinch.location(ofTouch: 1, in: elementsView)
            
            
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
    
    @objc func did(longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            let point = longPress.location(in: elementsView)
            
            let intersections = elementsView.subviews.filter { subview in
                return subview.layer.contains(elementsView.convert(point, to: subview))
            }
            
            guard !intersections.isEmpty else {
                return
            }
            
            let topMostViewOnly = [intersections.last!]

            selection = topMostViewOnly
            delegate?.didLongPress(designView: self, selection: selection as? [UIViewDesignable])
            
            longPress.isEnabled = false
            longPress.isEnabled = true
        default:
            break
        }
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
            
        }
        
        activeGestureRecognizers.insert(recognizer)
    }
    
    func gestureDidEnd(recognizer: UIGestureRecognizer) {
        activeGestureRecognizers.remove(recognizer)
        
        guard activeGestureRecognizers.isEmpty, let selection = selection else {
            return
        }
        
        (selection as! [UIViewDesignable]).forEach { $0.preGesturePositionDescription = nil }
        self.selection = nil
    }
    
    func remove(elements: [UIViewDesignable]) {
        let descriptions: [DesignableDescription] = elements.map { $0.designableDescription }
        print(descriptions)
        
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
            
            elementsView.addSubview(element)
            element.frame = CGRect(x: description.x, y: description.y, width: description.width, height: description.height)
        }
        
        return elements
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let singleTapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer {
            return singleTapGestureRecognizer.numberOfTapsRequired == 1 && singleTapGestureRecognizer.numberOfTouchesRequired == 1
        }
        return false
    }
    
    var layers: [DesignableDescription] {
        return (elementsView.subviews as! [UIViewDesignable]).map { $0.designableDescription }
    }
}
