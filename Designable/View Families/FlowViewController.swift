//
//  FlowViewController.swift
//  Designable
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class FlowViewController: UIViewController, DesignViewControllerInteractionDelegate {
    
    let flowInCaseOfRevert: Flow
    
    var project: Project
    var flow: Flow
    
    weak var projectViewController: ProjectViewController? = nil
    
    var navContainingDesignVCs = UINavigationController()
    
    init(project: Project, flow: Flow) {
        self.project = project
        self.flow = flow
        self.flowInCaseOfRevert = flow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        let moreItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapActions))
        navigationItem.setRightBarButtonItems([moreItem, editItem], animated: false)
        
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
        
        NSLog("Saved flow to project.")
    }
    
    func revertAndPopToProjectViewController() {
        projectViewController?.saveProjectWithUpdated(flowInCaseOfRevert)
        navigationController?.popViewController(animated: true)
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
    
    @objc func didTapActions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let hasUnsavedChanges = flow.toJSON() != flowInCaseOfRevert.toJSON()
        if hasUnsavedChanges {
            let revertAction = UIAlertAction(title: "Revert To Last Saved", style: .destructive, handler: { _ in
                let revertAlert = UIAlertController(title: "Revert to the last saved version of \"\(self.flow.name)\"?", message: "If you revert, any changes you have made since that version will be erased.", preferredStyle: .alert)
                revertAlert.addAction(UIAlertAction(title: "Revert", style: .destructive) { _ in
                    self.revertAndPopToProjectViewController()
                })
                revertAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(revertAlert, animated: true, completion: nil)
            })
            alert.addAction(revertAction)
        } else {
            let noRevertAction = UIAlertAction(title: "No Changes to Revert", style: .default, handler: nil)
            noRevertAction.isEnabled = false
            alert.addAction(noRevertAction)
        }
        
        alert.addAction(UIAlertAction(title: "Share Current Page", style: .default, handler: { _ in
            guard let designVC = self.navContainingDesignVCs.topViewController as? DesignViewController else {
                fatalError("Can't get designVC to get image.")
            }
            
            let image = designVC.designView.renderToImage()
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func didTap(designViewController: DesignViewController) {
        navigationController?.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
    
    
}
