//
//  ViewController.swift
//  Dream
//
//  Created by Sahand on 9/7/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Projects"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.setRightBarButton(addButton, animated: true)
    }
    
    @objc func didTapAdd() {
        navigationController?.pushViewController(DesignViewController(), animated: true)
    }


}

