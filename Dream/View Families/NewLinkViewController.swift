//
//  NewLinkViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import SnapKit

class NewLinkViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.44)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.title = "New Link to Page"
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
