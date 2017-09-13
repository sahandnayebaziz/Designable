//
//  FlowViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class FlowViewController: UIViewController, DesignViewControllerDataSource, DesignViewControllerInteractionDelegate {
    
    var project: Project
    var flow: Flow
    
    weak var projectViewController: ProjectViewController? = nil
    
    var navContainingDesignVCs = UINavigationController()
    
    init(project: Project, flow: Flow) {
        self.project = project
        self.flow = flow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        navigationItem.setRightBarButton(editItem, animated: false)
        
        let vc = DesignViewController(project: project, flow: flow, pageIndex: 0)
        vc.interactionDelegate = self
        vc.dataSource = self
        
        navContainingDesignVCs = UINavigationController(rootViewController: vc)
        addChildViewController(navContainingDesignVCs)
        view.addSubview(navContainingDesignVCs.view)
        navContainingDesignVCs.view.snp.makeConstraints { make in
            make.size.equalTo(view)
            make.center.equalTo(view)
        }
        navContainingDesignVCs.didMove(toParentViewController: self)
        navContainingDesignVCs.setNavigationBarHidden(true, animated: false)
        
//        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 1) { [ weak self ] in
//            self?.navigationController?.setNavigationBarHidden(!self!.navigationController!.isNavigationBarHidden, animated: true)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = flow.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveToProjectViewController()
    }
    
    func saveToProjectViewController() {
        guard let allDesignVCs = navContainingDesignVCs.viewControllers as? [DesignViewController] else {
            fatalError("Unexpected VC type in container navigation stack.")
        }
        
        allDesignVCs.forEach {
            flow.pages[$0.pageIndex].layers = $0.designView.layers
        }
        
        projectViewController?.saveProjectWithUpdated(flow)
    }
    
    func deleteFromProjectViewController() {
        projectViewController?.saveProjectAfterDeleting(flow)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapEdit() {
        let vc = EditFlowFormViewController(flow: flow)
        vc.flowViewController = self
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    func didTap(designViewController: DesignViewController) {
        navigationController?.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
}
