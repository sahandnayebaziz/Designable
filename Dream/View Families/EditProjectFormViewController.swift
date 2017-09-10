//
//  EditProjectFormViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import Eureka

class EditProjectFormViewController: FormViewController {
    
    let project: Project
    
    init(project: Project) {
        self.project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Project"
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel)), animated: false)
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave)), animated: false)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        form +++ Section()
            <<< NameRow() {
                $0.value = project.name
                
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
                $0.value = project.description
                
                $0.tag = "description"
                $0.placeholder = "What is this project about? (optional)"
                $0.add(rule: RuleRequired())
                $0.validationOptions = ValidationOptions.validatesOnChange
                $0.validate()
                }.cellUpdate { [ weak self ] _, _ in
                    self?.cellWasUpdated()
        }
        
        form +++ Section()
            <<< ButtonRow() {
                $0.tag = "delete"
                $0.title = "Delete"
                $0.cell.tintColor = .red
                }.onCellSelection { [weak self] _, _ in
                    self?.didTapDelete()
        }
        
    }
    
    
    func cellWasUpdated() {
        updateCreateButtonStatus()
    }
    
    func updateCreateButtonStatus() {
        let rowsAreValid = form.rows.count == form.rows.filter { $0.isValid }.count
        navigationItem.rightBarButtonItem?.isEnabled = rowsAreValid
    }
    
    func didTapDelete() {
        do {
            try Dream.delete(project: project)
            
            (presentingViewController as? UINavigationController)?.popViewController(animated: false)
            dismiss(animated: true, completion: nil)
        } catch {
            print(error as NSError)
        }
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapSave() {
        do {
            let editedProject = Project(name: form.values()["name"] as! String, description: form.values()["description"] as! String, flows: [])
            try Dream.delete(project: project)
            try Dream.save(newProject: editedProject)
            dismiss(animated: true, completion: nil)
        } catch {
            print(error as NSError)
        }
    }
    
    

}
