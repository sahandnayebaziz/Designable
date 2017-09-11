//
//  EditFlowFormViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import Eureka

class EditFlowFormViewController: FormViewController {
    
    let flow: Flow
    weak var flowViewController: FlowViewController? = nil
    
    init(flow: Flow) {
        self.flow = flow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Flow"
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel)), animated: false)
        navigationItem.setRightBarButton( UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave)), animated: false)
        
        form +++ Section()
            <<< NameRow() {
                $0.value = flow.name
                
                $0.tag = "name"
                $0.title = "Name"
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
    
    func cellWasUpdated() {
        updateSaveButtonStatus()
    }
    
    func updateSaveButtonStatus() {
        let rowsAreValid = form.rows.count == form.rows.filter { $0.isValid }.count
        navigationItem.rightBarButtonItem?.isEnabled = rowsAreValid
    }
    
    @objc func didTapCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSave() {
        var editedFlow = flow
        editedFlow.name = form.values()["name"] as! String
        flowViewController?.flow = editedFlow
        navigationController?.popViewController(animated: true)
    }

}
