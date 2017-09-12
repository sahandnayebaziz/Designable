//
//  InspectorMenuController.swift
//  Dream
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class InspectorMenuController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var selection: [UIViewDesignable]? = nil
    var attributes: [UIViewDesignableInspectableAttributeType] = []
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    weak var designViewController: DesignViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Dream.Colors.inspectorLightGray
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 110)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 24
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsetsMake(0, 30, 0, 30)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(InspectorMenuAttributeCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = Dream.Colors.inspectorLightGray
        
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone)), animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func didTapDone() {
        designViewController?.designView.selection = nil
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attributes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InspectorMenuAttributeCell
        let attribute = attributes[indexPath.row]
        cell.inspectorMenuController = self
        cell.set(for: attribute)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let attribute = attributes[indexPath.row]
        switch attribute {
        case .fillColor:
            let vc = InspectorColorViewController()
            vc.inspectorMenuController = self
            navigationController?.pushViewController(vc, animated: true)
        case .link:
            break
        case .image:
            let vc = InspectorImageViewController()
            vc.inspectorMenuController = self
            navigationController?.pushViewController(vc, animated: true)
        case .duplicate:
            guard let selected = designViewController?.designView.selection?.first as? UIViewDesignable else {
                fatalError("No selection")
                return
            }
            
            selected.inspectableDuplicate(inView: designViewController!.designView, recordedIn: designViewController!.designView.designUndoManager)
        }
    }
}

class InspectorMenuAttributeCell: UICollectionViewCell {
    
    weak var inspectorMenuController: InspectorMenuController? = nil
    var iconView: UIView? = nil
    var label: UILabel? = nil
    
    func set(for attribute: UIViewDesignableInspectableAttributeType) {
        if iconView == nil {
            iconView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            addSubview(iconView!)
            iconView!.backgroundColor = .white
            iconView!.layer.cornerRadius = 16
            iconView!.clipsToBounds = true
            
            label = UILabel()
            addSubview(label!)
            label!.frame = CGRect(x: 0, y: 87, width: 80, height: 33)
            label!.numberOfLines = 2
            label!.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            label!.textAlignment = .center
        }
        
        label!.text = attribute.menuOptionTitle
        iconView!.subviews.forEach { $0.removeFromSuperview() }
        attribute.setIconIn(view: iconView!, selection: inspectorMenuController!.selection!)
    }
    
}

class InspectorViewController: UIViewController {
    
    weak var inspectorMenuController: InspectorMenuController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone)), animated: false)
    }
    
    @objc func didTapDone() {
        inspectorMenuController?.didTapDone()
    }
    
}
