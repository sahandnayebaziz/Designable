//
//  DesignViewController.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

protocol DesignViewControllerDataSource: class {
    var project: Project { get set }
    var flow: Flow { get set }
}

protocol DesignViewControllerInteractionDelegate: class {
    func didTap(designViewController: DesignViewController)
}

class DesignViewController: UIViewController, DesignViewDelegate, UIGestureRecognizerDelegate {
    
    var project: Project
    var flow: Flow
    let pageIndex: Int
    
    weak var dataSource: DesignViewControllerDataSource? = nil
    weak var interactionDelegate: DesignViewControllerInteractionDelegate? = nil
    
    var designView = DesignView()
    var inspectorMenuVC = InspectorMenuController()
    var inspectorNavView = UIView()
    
    init(project: Project, flow: Flow, pageIndex: Int) {
        self.project = project
        self.flow = flow
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        }
        
        let vc = inspectorMenuVC
        vc.designViewController = self
        let nav = UINavigationController(rootViewController: vc)
        inspectorNavView = nav.view
        addChildViewController(nav)
        view.addSubview(inspectorNavView)
        inspectorNavView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(180)
            make.height.equalTo(180)
        }
        nav.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func didClearSelection() {
        setInspectorHidden(true, animated: true)
    }
    
    func didTap(designView: DesignView) {
        interactionDelegate?.didTap(designViewController: self)
    }
    
    func didLongPress(designView: DesignView, selection: [UIViewDesignable]?) {
        if let selected = selection?.first {
            
            inspectorMenuVC.selection = selection
            inspectorMenuVC.attributes = selected.inspectableAttributeTypes
            
            inspectorMenuVC.collectionView.reloadData()
            
            self.setInspectorHidden(false, animated: true)
        }
    }
    
    func didSelectCreateNewPage() {
        guard let flowVC = dataSource else {
            fatalError("Can't work without a data source.")
        }
        
        guard let selected = designView.selection?.first as? UIViewDesignable else {
            fatalError("Trying to link a page without a selection.")
        }
        
        // prepare new flow version
        var newFlow = flow
        
        // add new page
        let newPage = Page(id: UUID().uuidString, name: "Page \(newFlow.pages.count + 1)", layers: [])
        newFlow.pages.append(newPage)
        
        // link selection to new page
        selected.link = DesignableDescriptionLink(type: .push, toPageId: newPage.id, toFlowId: flow.id)
        
        // save current layers to new flow version
        newFlow.pages[pageIndex].layers = designView.layers
        
        // send new flow version to parent view controller and self
        flowVC.flow = newFlow
        self.flow = newFlow
        
        // push to new view controller
        pushNewDesignViewController(atPageIndex: flow.pages.count - 1)
    }
    
    func didSelectLink(_ page: Page, _ flow: Flow) {
        guard let flowVC = dataSource else {
            fatalError("Can't work without a data source.")
        }
        
        guard let selected = designView.selection?.first as? UIViewDesignable else {
            fatalError("Trying to link a page without a selection.")
        }
        
        guard let linkingToPageIndex = flow.pages.index(where: { $0.id == page.id }) else {
            fatalError("Trying to link to a page that is not in the flow.")
        }
        
        // prepare new flow version
        var newFlow = flow
        
        // link selection to page
        selected.link = DesignableDescriptionLink(type: .push, toPageId: page.id, toFlowId: flow.id)
        
        // save current layers to new flow version
        newFlow.pages[pageIndex].layers = designView.layers
        
        // send new flow version to parent view controller and self
        flowVC.flow = newFlow
        self.flow = newFlow
        
        // push to new view controller
        pushNewDesignViewController(atPageIndex: linkingToPageIndex)
    }
    
    func pushNewDesignViewController(atPageIndex index: Int) {
        let designVC = DesignViewController(project: project, flow: flow, pageIndex: index)
        designVC.interactionDelegate = interactionDelegate
        designVC.dataSource = dataSource
        navigationController?.pushViewController(designVC, animated: true)
    }
    
    func saveCurrentPageDesign() {
        guard let flowVC = dataSource else {
            fatalError("Can't work without a data source.")
        }
        
        let newLayers = designView.layers
        flowVC.flow.pages[pageIndex].layers = newLayers
    }
    
    func setInspectorHidden(_ hidden: Bool, animated: Bool) {
        let animationTime = animated ? 0.25 : 0
        let bottomOffset = hidden ? 180 : 0
        UIView.animate(withDuration: animationTime, animations: {
            self.inspectorNavView.snp.updateConstraints { make in
                make.height.equalTo(180)
                make.bottom.equalTo(bottomOffset)
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.inspectorMenuVC.navigationController?.popToRootViewController(animated: false)
        })
    }
    
}
