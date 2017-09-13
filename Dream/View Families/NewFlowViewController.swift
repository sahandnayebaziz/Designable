//
//  NewFlowViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class NewFlowViewController: FlowViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel)), animated: false)
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        navigationItem.setRightBarButtonItems([saveItem, editItem], animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {}
    
    override func didTapEdit() {
        let vc = EditFlowFormViewController(flow: flow)
        vc.flowViewController = self
        vc.isNewUnsavedFlow = true
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapSave() {
        saveToProjectViewController()
        dismiss(animated: true, completion: nil)
    }
    

}
