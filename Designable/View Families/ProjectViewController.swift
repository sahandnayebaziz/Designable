//
//  ProjectViewController.swift
//  Designable
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit
import SnapKit

class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        tableView.register(FlowTableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FlowTableViewCell
        let flow = project.flows[indexPath.row]
        cell.set(for: flow)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let flow = project.flows[indexPath.row]
        
        let flowVC = FlowViewController(project: project, flow: flow)
        flowVC.projectViewController = self
        navigationController?.pushViewController(flowVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    @objc func didTapEdit() {
        let vc = UINavigationController(rootViewController: EditProjectFormViewController(project: project))
        vc.modalPresentationStyle = .currentContext
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapNewFlow() {
        let newPage = Page(name: "Page 1", bounds: view.frame)
        let newFlow = Flow(id: UUID().uuidString, name: "Untitled", pages: [newPage])
        
        let flowVC = FlowViewController(project: project, flow: newFlow)
        flowVC.projectViewController = self
        navigationController?.pushViewController(flowVC, animated: true)
    }
    
    func saveProjectWithUpdated(_ flow: Flow) {
        let existingFlowIndex = project.flows.index(where: { $0.id == flow.id })
        if let existingFlowIndex = existingFlowIndex {
            project.flows[existingFlowIndex] = flow
        } else {
            project.flows.insert(flow, at: 0)
        }
        
        dispatch_to_background_queue(.utility) {
            Designable.save(self.project)
        }
    }
    
    func saveProjectAfterDeleting(_ flow: Flow) {
        let existingFlowIndex = project.flows.index(where: { $0.id == flow.id })
        if let existingFlowIndex = existingFlowIndex {
            project.flows.remove(at: existingFlowIndex)
        }
        
        Designable.save(project)
    }

}

class FlowTableViewCell: UITableViewCell {
    
    var flowId: String = ""
    
    var previewImageView: UIImageView? = nil
    var nameLabel: UILabel? = nil
    
    func set(for flow: Flow) {
        flowId = flow.id
        
        if previewImageView == nil {
            previewImageView = UIImageView()
            addSubview(previewImageView!)
            previewImageView!.snp.makeConstraints { make in
                make.height.equalTo(80)
                make.width.equalTo(80)
                make.top.equalTo(20)
                make.left.equalTo(self).offset(14)
                make.centerY.equalTo(self)
            }
            previewImageView!.contentMode = .scaleAspectFit
            previewImageView!.backgroundColor = Designable.Colors.imageViewBackgroundGray
            previewImageView!.layer.cornerRadius = 4
            
            nameLabel = UILabel()
            addSubview(nameLabel!)
            nameLabel!.snp.makeConstraints { make in
                make.left.equalTo(previewImageView!.snp.right).offset(14)
                make.centerY.equalTo(self)
                make.right.equalTo(self).offset(-14)
                make.height.equalTo(self)
            }
            nameLabel!.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .semibold)
        }
        
        previewImageView!.image = nil
        nameLabel!.text = flow.name
        flow.renderThumbnail(id: flowId) { [ weak self ] id, image in
            if let strongSelf = self {
                if strongSelf.flowId == id {
                    NSLog("placing \(id)")
                    strongSelf.previewImageView?.image = image
                }
            }
        }
    }
}

extension Flow {
    func renderThumbnail(id: String, completion: @escaping (String, UIImage) -> Void) {
        NSLog("rendering \(id)")
        dispatch_to_background_queue(.userInitiated) {
            var view: UIView? = UIView(frame: UIScreen.main.bounds)
            NSLog("View created done.")
            view?.backgroundColor = .white
            self.pages[0].layers.forEach { view?.addSubview($0.toUIViewDesignable() as! UIView) }
            NSLog("Added subviews done.")
            guard let elements = view?.subviews as? [UIView & UIViewDesignable] else {
                fatalError("Not elements again")
            }
            
            var allElementsRendered = false
            while !allElementsRendered {
                NSLog("Waiting for elements to render.")
                let elementsRendered = elements.filter {
                    switch $0.type {
                    case .rectangle:
                        return true
                    case .image:
                        return ($0 as! UIViewDesignableImageUIView).image != nil
                    }
                }
                allElementsRendered = elements.count == elementsRendered.count
            }
            NSLog("All elements rendered done.")
            
            let image = view!.renderToImage(.fast)
            NSLog("Image rendered done.")
            view = nil
            dispatch_to_main_queue {
                NSLog("returning \(id)")
                completion(id, image)
            }
        }
    }
}
