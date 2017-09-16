//
//  ProjectsViewController.swift
//  Designable
//
//  Created by Sahand on 9/7/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import SnapKit

class ProjectsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var projects: [Project] = []
    
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Projects"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProjectTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.setRightBarButton(addButton, animated: true)
        
        dispatch_to_background_queue(.userInteractive) {
            let projects = Designable.loadProjects()
            dispatch_to_main_queue {
                self.projects = projects
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func didTapAdd() {
        let vc = UINavigationController(rootViewController: NewProjectFormViewController())
        vc.modalPresentationStyle = .currentContext
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true, completion: nil)        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProjectTableViewCell
        let project = projects[indexPath.row]
        cell.set(for: project)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(ProjectViewController(project: projects[indexPath.row]), animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }

}

class ProjectTableViewCell: UITableViewCell {
    
    var nameLabel: UILabel? = nil
    var descriptionLabel: UILabel? = nil
    
    func set(for project: Project) {
        if nameLabel == nil {
            nameLabel = UILabel()
            addSubview(nameLabel!)
            nameLabel!.snp.makeConstraints { make in
                make.top.equalTo(12)
                make.left.equalTo(24)
                make.right.equalTo(self).offset(-14)
            }
            nameLabel!.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .medium)
            
            descriptionLabel = UILabel()
            addSubview(descriptionLabel!)
            descriptionLabel!.snp.makeConstraints { make in
                make.top.equalTo(nameLabel!.snp.bottom).offset(2)
                make.left.equalTo(24)
                make.right.equalTo(self).offset(-14)
                make.bottom.equalTo(self).offset(-10)
            }
            descriptionLabel!.font = UIFont.preferredFont(forTextStyle: .callout)
            descriptionLabel!.textColor = Designable.Colors.tableViewCellSubtitleGray
        }
        
        nameLabel!.text = project.name
        descriptionLabel!.text = project.description
    }
    
}

