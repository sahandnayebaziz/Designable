//
//  DesignViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

protocol DesignViewControllerDelegate: class {
    func didSave(flow: Flow)
}

class DesignViewController: UIViewController, DesignViewDelegate {
    
    var flow: Flow
    
    init(flow: Flow?) {
        if let flow = flow {
            self.flow = flow
        } else {
            self.flow = Flow(id: UUID().uuidString, name: "Untitled", pages: [Page(id: UUID().uuidString, layers: [])])
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var designView = DesignView()
    weak var delegate: DesignViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel)), animated: false)
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        
        navigationItem.setRightBarButtonItems([saveItem, editItem], animated: false)
        
        designView.delegate = self
        view.addSubview(designView)
        designView.snp.makeConstraints { make in
            make.size.equalTo(view)
            make.center.equalTo(view)
        }
        
        flow.pages[0].layers.forEach { l in
            let view = l.toUIViewDesignable() as! UIView
            designView.elementsView.addSubview(view)
            view.frame = CGRect(x: l.x, y: l.y, width: l.width, height: l.height)            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = flow.name
    }
    
    func didTap(designView: DesignView) {
        navigationController?.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
    
    func didLongPress(designView: DesignView) {
        let vc = NewLinkViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapEdit() {
        let vc = UINavigationController(rootViewController: EditFlowFormViewController(flow: flow))
        vc.modalPresentationStyle = .currentContext
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapSave() {
        save()
        dismiss(animated: true, completion: nil)
    }
    
    func save() {
        flow.pages[0].layers = designView.layers
        delegate?.didSave(flow: flow)
    }
    
}
