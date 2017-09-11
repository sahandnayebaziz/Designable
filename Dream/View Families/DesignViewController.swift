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

class DesignViewController: UIViewController, DesignViewDelegate, EditFlowFormViewControllerDelegate {
    
    var project: Project
    var flow: Flow
    
    init(project: Project, flow: Flow) {
        self.project = project
        self.flow = flow
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
    
    @objc func didTapEdit() {
        let vc = EditFlowFormViewController(flow: flow)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didEditFlow(flow: Flow) {
        self.flow = flow
        save()
    }
    
    @objc func didTapSave() {
        save()
        navigationController?.popViewController(animated: true)
    }
    
    func save() {
        flow.pages[0].layers = designView.layers
        delegate?.didSave(flow: flow)
    }
    
}
