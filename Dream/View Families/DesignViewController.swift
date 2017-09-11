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

protocol DesignViewControllerDataSource: class {
    var project: Project { get set }
    var flow: Flow { get set }
}

protocol DesignViewControllerInteractionDelegate: class {
    func didTap(designViewController: DesignViewController)
}

class DesignViewController: UIViewController, DesignViewDelegate, NewLinkViewControllerDelegate, UIGestureRecognizerDelegate {
    
    var project: Project
    var flow: Flow
    let pageIndex: Int
    
    weak var dataSource: DesignViewControllerDataSource? = nil
    weak var interactionDelegate: DesignViewControllerInteractionDelegate? = nil
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func didTap(designView: DesignView) {
        interactionDelegate?.didTap(designViewController: self)
    }
    
    func didLongPress(designView: DesignView) {
        let vc = NewLinkViewController(project: project, flow: flow)
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    
    func didSelectCreateNewPage() {
        let nav = navigationController!
        
        flow.pages.append(Page(id: UUID().uuidString, name: "Page \(flow.pages.count + 1)", layers: []))
        let designVC = DesignViewController(project: project, flow: flow, pageIndex: flow.pages.count - 1)
        designVC.delegate = delegate
        designVC.interactionDelegate = interactionDelegate
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
//        save()
        
        let designVC = DesignViewController(project: project, flow: flow, pageIndex: pageIndex)
        designVC.delegate = delegate
        designVC.interactionDelegate = interactionDelegate
        navigationController?.pushViewController(designVC, animated: true)
    }
    
    func saveCurrentPageDesign() {
        guard let flowVC = dataSource else {
            fatalError("Can't save without a data source.")
        }
        
        let newLayers = designView.layers
        flowVC.flow.pages[pageIndex].layers = newLayers
    }
    
}
