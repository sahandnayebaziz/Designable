//
//  DesignViewController.swift
//  Designable
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

protocol DesignViewControllerInteractionDelegate: class {
    func didTap(designViewController: DesignViewController)
}

class DesignViewController: UIViewController, DesignViewDelegate, UIGestureRecognizerDelegate {
    
    var project: Project
    var flow: Flow
    let pageIndex: Int
    
    weak var flowViewController: FlowViewController? = nil
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
            make.width.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(180)
            make.height.equalTo(180)
        }
        nav.didMove(toParentViewController: self)
        
        setInspectorHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setInspectorHidden(_ hidden: Bool, animated: Bool) {
        let animationTime = animated ? 0.25 : 0
        let bottomOffset = hidden ? 180 : 0
        let alpha: CGFloat = hidden ? 0 : 1
        UIView.animate(withDuration: animationTime, animations: {
            self.inspectorNavView.snp.updateConstraints { make in
                make.height.equalTo(180)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(bottomOffset)
            }
            self.inspectorNavView.alpha = alpha
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.inspectorMenuVC.navigationController?.popToRootViewController(animated: false)
        })
    }
    
    func saveCurrentPageDesign() {
        guard let flowVC = flowViewController else {
            fatalError("Can't work without a data source.")
        }
        
        let newLayers = designView.layers
        flowVC.flow.pages[pageIndex].layers = newLayers
        
        flowVC.saveToProjectViewController()
    }
    
    func didChange(_ designView: DesignView) {
        saveCurrentPageDesign()
    }
    
    func didClearSelection() {
        setInspectorHidden(true, animated: true)
    }
    
    func didTapEmptyOrUnlinkedSpace(designView: DesignView) {
        interactionDelegate?.didTap(designViewController: self)
    }
    
    func didTapLink(designView: DesignView, link: DesignableDescriptionLink) {
        guard let linkingToPageIndex = flow.pages.index(where: { $0.id == link.toPageId }) else {
            fatalError("Can't find page in flow for link.")
        }
        
        pushNewDesignViewController(atPageIndex: linkingToPageIndex)
    }
    
    func didLongPress(designView: DesignView, selection: [UIViewDesignable]?) {
        if let selected = selection?.first {
            inspectorMenuVC.attributes = selected.inspectableAttributeTypes
            inspectorMenuVC.collectionView.reloadData()
            setInspectorHidden(false, animated: true)
        }
    }
    
    func didSelectCreateNewPage() {
        guard let flowVC = flowViewController else {
            fatalError("Can't work without a data source.")
        }
        
        guard let selected = designView.selection?.first else {
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
        guard let flowVC = flowViewController else {
            fatalError("Can't work without a data source.")
        }
        
        guard let selected = designView.selection?.first else {
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
        designVC.flowViewController = flowViewController
        designVC.interactionDelegate = interactionDelegate
        navigationController?.pushViewController(designVC, animated: true)
    }
}
