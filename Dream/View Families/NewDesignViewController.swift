//
//  NewDesignViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class NewDesignViewController: DesignViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel)), animated: false)
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
//    
//    override func didTapSave() {
//        save()
//        dismiss(animated: true, completion: nil)
//    }
//    
//    override func didEditFlow(flow: Flow) {
//        self.flow = flow
//    }
}
