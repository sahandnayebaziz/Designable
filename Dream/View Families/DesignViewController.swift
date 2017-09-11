//
//  DesignViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

protocol DesignViewControllerDelegate: class {
    func didSave(flow: Flow)
}

class DesignViewController: UIViewController, DesignViewDelegate, EditFlowFormViewControllerDelegate, NewLinkViewControllerDelegate {
    
    var project: Project
    var flow: Flow
    let pageIndex: Int
    
    init(project: Project, flow: Flow, pageIndex: Int) {
        self.project = project
        self.flow = flow
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var designView = DesignView()
    weak var delegate: DesignViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        navigationItem.setRightBarButtonItems([saveItem, editItem], animated: false)
        
        designView.delegate = self
        view.addSubview(designView)
        designView.snp.makeConstraints { make in
            make.size.equalTo(view)
            make.center.equalTo(view)
        }
        
        flow.pages[pageIndex].layers.forEach { l in
            let view = l.toUIViewDesignable() as! UIView
            designView.elementsView.addSubview(view)
            view.frame = CGRect(x: l.x, y: l.y, width: l.width, height: l.height)            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "\(flow.pages[pageIndex].name) — \(flow.name)"
    }
    
    func didTap(designView: DesignView) {
        navigationController?.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
    
    func didLongPress(designView: DesignView) {
        let vc = NewLinkViewController(project: project, flow: flow)
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapEdit() {
        let vc = EditFlowFormViewController(flow: flow)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didEditFlow(flow: Flow) {
        self.flow = flow
        save()
    }
    
    @objc func didTapSave() {
        let nav = navigationController!
        
        save()
        if nav.viewControllers.count > 2 {
            if let prevDesignVC = nav.viewControllers[nav.viewControllers.count - 2] as? DesignViewController {
                prevDesignVC.project = project
                prevDesignVC.flow = flow
            }
        }
        nav.popViewController(animated: true)
    }
    
    func save() {
        flow.pages[pageIndex].layers = designView.layers
        delegate?.didSave(flow: flow)
    }
    
    func didSelectCreateNewPage() {
        let nav = navigationController!
        
        flow.pages.append(Page(id: UUID().uuidString, name: "Page \(flow.pages.count + 1)", layers: []))
        let designVC = DesignViewController(project: project, flow: flow, pageIndex: flow.pages.count - 1)
        designVC.delegate = delegate
        nav.pushViewController(designVC, animated: true)
    }
    
    func didSelectLink(_ page: Page, _ flow: Flow) {
        guard let _ = designView.selection?.first as? UIViewDesignable else {
            fatalError("Trying to link a page without a selection.")
        }
        
        guard let pageIndex = flow.pages.index(where: { $0.id == page.id }) else {
            fatalError("Trying to link to a page that is not in the flow.")
        }
        
        (designView.selection?.first as! UIViewDesignable).link = DesignableDescriptionLink(type: .push, toPageId: page.id, toFlowId: flow.id)
        save()
        
        let designVC = DesignViewController(project: project, flow: flow, pageIndex: pageIndex)
        designVC.delegate = delegate
        navigationController?.pushViewController(designVC, animated: true)
    }
    
}
