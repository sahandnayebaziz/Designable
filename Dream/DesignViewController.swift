//
//  DesignViewController.swift
//  Dream
//
//  Created by Sahand on 9/7/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class DesignViewController: UIViewController {
    
    var selection: [DesignableUIView]? = nil {
        didSet {
            if let selection = selection {
                selection.forEach { $0.backgroundColor = .blue }
            } else {
                view.subviews.forEach { $0.backgroundColor = .lightGray }
            }
        }
    }
    var selectionCenterAtStartOfGesture: CGPoint? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let squareView = DesignableUIView()
        squareView.backgroundColor = UIColor.lightGray
        view.addSubview(squareView)
        squareView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        squareView.center = view.center
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(did(pan:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func did(pan: UIPanGestureRecognizer) {
        guard pan.numberOfTouches < 2 else {
            return
        }

        switch pan.state {
        case .began:
            let point = pan.location(ofTouch: 0, in: view)
            let intersections = view.subviews.filter { $0.layer.contains(view.convert(point, to: $0))}
            guard !intersections.isEmpty else {
                return
            }
            
            selection = intersections as? [DesignableUIView]
            selectionCenterAtStartOfGesture = selection!.first!.center
        case .changed:
            guard let selection = selection, let selectionCenterAtStartOfGesture = selectionCenterAtStartOfGesture else {
                return
            }
            
            let translation = pan.translation(in: view)
            selection.first!.center = selectionCenterAtStartOfGesture
            selection.first!.frame = selection.first!.frame.applying(CGAffineTransform(translationX: translation.x, y: translation.y))
        case .cancelled,
             .ended,
             .failed:
            selection = nil
            selectionCenterAtStartOfGesture = nil
        default:
            break
        }   
    }
}

class DesignableUIView: UIView {
    var preGestureFrame: CGRect? = nil
}
