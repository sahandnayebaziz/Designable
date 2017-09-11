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
    
    var isNewUnsavedFlow = false
    
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
        
        
        if !isNewUnsavedFlow {
            form +++ Section()
                <<< ButtonRow() {
                    $0.tag = "delete"
                    $0.title = "Delete"
                    $0.cell.tintColor = .red
                    }.onCellSelection { [weak self] _, _ in
                        self?.didTapDelete()
            }
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
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapSave() {
        var editedFlow = flow
        editedFlow.name = form.values()["name"] as! String
        flowViewController?.flow = editedFlow
        dismiss(animated: true, completion: nil)
    }
    
    func didTapDelete() {
        let alert = UIAlertController(title: "Delete \"\(flow.name)\"?", message: "If you delete this flow, you won't be able to see it again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.flowViewController?.deleteFromProjectViewController()
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
