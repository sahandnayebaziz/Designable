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

protocol NewLinkViewControllerDelegate: class {
    func didSelectCreateNewPage()
    func didSelectLink(_ page: Page, _ flow: Flow)
}

class NewLinkViewController: UIViewController, NewLinkTableViewControllerDelegate {
    
    var project: Project
    var flow: Flow
    
    weak var delegate: NewLinkViewControllerDelegate? = nil
    
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
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.44)
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.size.equalTo(view)
            make.center.equalTo(view)
        }
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        
        let vc = NewLinkTableViewController(project: project, flow: flow)
        vc.delegate = self
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
    
    func didSelectCreateNewPage() {
        dismiss(animated: true) { [ weak self ] in
            self?.delegate?.didSelectCreateNewPage()
        }
    }
    
    func didSelectLink(_ page: Page) {
        dismiss(animated: true) { [ weak self ] in
            self?.delegate?.didSelectLink(page, self!.flow)
        }
    }

}
