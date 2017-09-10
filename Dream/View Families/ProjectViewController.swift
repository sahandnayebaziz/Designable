//
//  ProjectViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import SnapKit

class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewDesignViewControllerDelegate {
    
    var project: Project
    
    let tableView = UITableView()
    
    init(project: Project) {
        self.project = project
        super.init(nibName: nil, bundle: nil)
        
        let editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEdit))
        let newItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapNewFlow))
        navigationItem.setRightBarButtonItems([newItem, editItem], animated: false)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        
        title = project.name
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project.flows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let flow = project.flows[indexPath.row]
        cell.textLabel?.text = flow.name
        return cell
    }
    
    @objc func didTapEdit() {
        let vc = UINavigationController(rootViewController: EditProjectFormViewController(project: project))
        vc.modalPresentationStyle = .currentContext
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapNewFlow() {
        let newDesignVC = NewDesignViewController()
        newDesignVC.delegate = self
        let vc = UINavigationController(rootViewController: newDesignVC)
        vc.modalPresentationStyle = .currentContext
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true, completion: nil)
    }
    
    func didCreateNewFlow(flow: Flow) {
        project.flows.append(flow)
        Dream.save(project)
    }

}
