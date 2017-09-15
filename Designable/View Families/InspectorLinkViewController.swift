//
//  NewLinkTableViewController.swift
//  Designable
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

enum NewLinkViewControllerActionType {
    case newPage
}

class InspectorLinkViewController: InspectorViewController, UITableViewDataSource, UITableViewDelegate {
    
    var project: Project
    var flow: Flow
    
    let actions: [NewLinkViewControllerActionType] = [.newPage]
    
    let tableView = UITableView()
    
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
        view.backgroundColor = .white
        title = "New Link to Page"
        
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return actions.count
        } else {
            return flow.pages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (indexPath.section == 0) {
            cell.textLabel?.text = "Create new page"
        } else {
            let flowForRow = flow.pages[indexPath.row]
            cell.textLabel?.text = flowForRow.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let action = actions[indexPath.row]
            switch action {
            case .newPage:
                inspectorMenuController?.designViewController?.didSelectCreateNewPage()
            }
        } else if indexPath.section == 1 {
            let page = flow.pages[indexPath.row]
            inspectorMenuController?.designViewController?.didSelectLink(page, inspectorMenuController!.designViewController!.flow)
        }
    }
}
