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
    func didChange(_ designView: DesignView)
    func didTapEmptyOrUnlinkedSpace(designView: DesignView)
    func didLongPress(designView: DesignView, selection: [UIViewDesignable]?)
    func didClearSelection()
    func didTapLink(designView: DesignView, link: DesignableDescriptionLink)
}

struct DesignablePreGestureDescription {
    let center: CGPoint
    let width: CGFloat
    let height: CGFloat
    
    var frame: CGRect {
        return CGRect(x: center.x - (width / 2), y: center.y - (height / 2), width: width, height: height)
    }
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
        clipsToBounds = true
        
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
        
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        singleTapGestureRecognizer.require(toFail: longPressGestureRecognizer)
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
        switch singleTap.state {
        case .ended:
            let point = singleTap.location(in: elementsView)
            
            let intersections = elementsView.subviews.filter { subview in
                return subview.layer.contains(elementsView.convert(point, to: subview))
            }
            
            if intersections.isEmpty {
                delegate?.didTapEmptyOrUnlinkedSpace(designView: self)
                selection = nil
            } else {
                let topMostViewOnly = intersections.last! as! UIViewDesignable
                if let link = topMostViewOnly.link {
                    delegate?.didTapLink(designView: self, link: link)
                } else {
                    delegate?.didTapEmptyOrUnlinkedSpace(designView: self)
                }
            }
        default:
            break
        }
        
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
        default:
            break
        }
    }
    
    func gestureDidBegin(withViews views: [UIViewDesignable], from recognizer: UIGestureRecognizer) {
        if activeGestureRecognizers.isEmpty {
            guard let selectionAsViews = views as? [UIView] else {
                print(views)
                fatalError("Couldn't get views from bad selection.")
            }
            selection = selectionAsViews
            
            guard let firstElementAsUIView = views.first as? UIView, let firstElementAsDesignable = views.first else {
                print(views)
                fatalError("Made selection without a first element, or without a first element that is a designable.")
            }
            
            firstElementAsDesignable.preGesturePositionDescription = DesignablePreGestureDescription(center: firstElementAsUIView.center, width: firstElementAsUIView.frame.width, height: firstElementAsUIView.frame.height)
        }
        
        activeGestureRecognizers.insert(recognizer)
    }
    
    func gestureDidEnd(recognizer: UIGestureRecognizer) {
        activeGestureRecognizers.remove(recognizer)
        
        if activeGestureRecognizers.isEmpty {
            
            guard let firstElementAsUIView = selection?.first, let firstElementAsDesignable = selection?.first as? UIViewDesignable else {
                print(selection as Any)
                fatalError("Made selection without a first element, or without a first element that is a designable.")
            }
            
            guard let firstElementAsDesignablePreGesture = firstElementAsDesignable.preGesturePositionDescription else {
                print(selection as Any)
                fatalError("Gesture ended on an element that wasn't given a pre gesture position.")
            }
            
            undoableSetFrameOf(view: firstElementAsUIView, fromFrame: firstElementAsDesignablePreGesture.frame, toFrame: firstElementAsUIView.frame)
            
            firstElementAsDesignable.preGesturePositionDescription = nil
            
            self.selection = nil
            delegate?.didChange(self)
        }
    }
    
    func undoableSetFrameOf(view: UIView, fromFrame: CGRect, toFrame: CGRect) {
        designUndoManager.registerUndo(withTarget: self) { [ weak view ] designView in
            if let v = view {
                designView.undoableSetFrameOf(view: v, fromFrame: toFrame, toFrame: fromFrame)
            }
        }
        
        view.frame = toFrame
        delegate?.didChange(self)
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
            
            elementsView.addSubview(element)
            element.frame = CGRect(x: description.x, y: description.y, width: description.width, height: description.height)
        }
        
        return elements
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let interactiveSwipeBack = (delegate as? DesignViewController)?.navigationController?.interactivePopGestureRecognizer else {
            return false
        }
        
        // block a gesture from happening in this view if gesture happening already is the screen edge pan in the parent
        if otherGestureRecognizer == interactiveSwipeBack {
            return true
        }
        
        return false
    }
    
    var layers: [DesignableDescription] {
        return (elementsView.subviews as! [UIViewDesignable]).map { $0.designableDescription }
    }
}
