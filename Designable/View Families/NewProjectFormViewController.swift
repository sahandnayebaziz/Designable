//
//  NewProjectFormViewController.swift
//  Designable
//
//  Created by Sahand on 9/9/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import Eureka

class NewProjectFormViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Create Project"
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel)), animated: false)
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTapCreate)), animated: false)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        form +++ Section()
            <<< NameRow() {
                $0.tag = "name"
                $0.title = "Name"
                $0.add(rule: RuleRequired())
                $0.validationOptions = ValidationOptions.validatesOnChange
                $0.validate()
                
                }.cellUpdate { [ weak self ] _, _ in
                    self?.cellWasUpdated()
        }
            
        form +++ Section()
            <<< TextAreaRow() {
                $0.tag = "description"
                $0.placeholder = "What is this project about? (optional)"
                $0.add(rule: RuleRequired())
                $0.validationOptions = ValidationOptions.validatesOnChange
                $0.validate()
                }.cellUpdate { [ weak self ] _, _ in
                    self?.cellWasUpdated()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        form.rowBy(tag: "name")?.baseCell.cellBecomeFirstResponder()
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapCreate() {
        let project = Project(name: form.values()["name"] as! String, description: form.values()["description"] as! String, flows: [])
        Designable.save(project)
        dismiss(animated: true, completion: nil)
    }
    
    func cellWasUpdated() {
        updateCreateButtonStatus()
    }
    
    func updateCreateButtonStatus() {
        let rowsAreValid = form.rows.count == form.rows.filter { $0.isValid }.count
        navigationItem.rightBarButtonItem?.isEnabled = rowsAreValid
    }
}


