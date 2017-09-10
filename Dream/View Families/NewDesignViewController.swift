//
//  NewDesignViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

protocol NewDesignViewControllerDelegate: class {
    func didCreateNewFlow(flow: Flow)
}

class NewDesignViewController: UIViewController, DesignViewDelegate {
    
    var designView = DesignView()
    weak var delegate: NewDesignViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Untitled"
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel)), animated: false)
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave)), animated: false)
        
        designView.delegate = self
        view.addSubview(designView)
        designView.snp.makeConstraints { make in
            make.size.equalTo(view)
            make.center.equalTo(view)
        }
    }
    
    func didTap(designView: DesignView) {
        navigationController?.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapSave() {
        let newPage = Page(id: UUID().uuidString, layers: designView.layers)
        delegate?.didCreateNewFlow(flow: Flow(name: "Untitled", pages: [newPage]))
        
        dismiss(animated: true, completion: nil)
    }
    
}
