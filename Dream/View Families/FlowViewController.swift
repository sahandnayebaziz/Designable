//
//  FlowViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class FlowViewController: UIViewController, DesignViewControllerInteractionDelegate {
    
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
        
        setNavigationHasUnsavedChanges(false, animated: false)
        
        let vc = DesignViewController(project: project, flow: flow, pageIndex: 0)
        vc.flowViewController = self
        vc.interactionDelegate = self
        
        navContainingDesignVCs = UINavigationController(rootViewController: vc)
        addChildViewController(navContainingDesignVCs)
        view.addSubview(navContainingDesignVCs.view)
        navContainingDesignVCs.view.snp.makeConstraints { make in
            make.size.equalTo(view)
            make.center.equalTo(view)
        }
        navContainingDesignVCs.didMove(toParentViewController: self)
        navContainingDesignVCs.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = flow.name
    }
    
    func saveToProjectViewController() {
        guard let projectViewController = projectViewController else {
            fatalError("Can't work without project view controller")
        }
        
        guard let allDesignVCs = navContainingDesignVCs.viewControllers as? [DesignViewController] else {
            fatalError("Unexpected VC type in container navigation stack.")
        }
        
        allDesignVCs.forEach {
            flow.pages[$0.pageIndex].layers = $0.designView.layers
        }
        
        projectViewController.saveProjectWithUpdated(flow)
        project = projectViewController.project
    }
    
    func deleteFromProjectViewController() {
        projectViewController?.saveProjectAfterDeleting(flow)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapDiscard() {
        let alert = UIAlertController(title: "Discard changes made to \"\(flow.name)\"?", message: "If you discard the changes, this flow will go back to how it was when it was last saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapSave() {
        saveToProjectViewController()
        checkHasUnsavedChanges()
    }
    
    @objc func didTapEdit() {
        let vc = EditFlowFormViewController(flow: flow)
        vc.flowViewController = self
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    func didTap(designViewController: DesignViewController) {
        navigationController?.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
        checkHasUnsavedChanges()
    }
    
    func checkHasUnsavedChanges() {
        guard let flowInProject = project.flows.first(where: { $0.id == flow.id }) else {
            fatalError("Checking for unsaved changes when this flow doesn't exist in the project yet.")
        }
        setNavigationHasUnsavedChanges(flowInProject.toJSON() != flow.toJSON(), animated: true)
    }
    
    func setNavigationHasUnsavedChanges(_ hasUnsavedChanges: Bool, animated: Bool) {
        if hasUnsavedChanges {
            let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
            let discardItem = UIBarButtonItem(title: "Discard", style: .plain, target: self, action: #selector(didTapDiscard))
            discardItem.tintColor = .red
            
            navigationItem.setLeftBarButtonItems([discardItem, saveItem], animated: animated)
        } else {
            navigationItem.setLeftBarButtonItems(nil, animated: animated)
            
            let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
            navigationItem.setRightBarButton(editItem, animated: animated)
        }
    }
}
