//
//  NewLinkViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import SnapKit

enum NewLinkViewControllerActionType {
    case newPage
}

class NewLinkViewController: UIViewController {
    
    var project: Project
    var flow: Flow
    
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
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.44)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        
        let vc = NewLinkTableViewController(project: project, flow: flow)
        let nav = UINavigationController(rootViewController: vc)
        addChildViewController(nav)
        view.addSubview(nav.view)
        nav.view.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.centerX.equalTo(view)
            make.bottom.equalTo(view)
            make.height.equalTo(250)
        }
        nav.didMove(toParentViewController: self)
        
    }
    
    @objc func didTapView() {
        dismiss(animated: true, completion: nil)
    }

}
