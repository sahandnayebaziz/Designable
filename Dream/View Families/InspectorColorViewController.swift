//
//  InspectorColorViewController.swift
//  Dream
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class InspectorColorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private static func getColorFrom(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(displayP3Red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    let colors: [UIColor] = [
        .white,
        .lightGray,
        .black,
        getColorFrom(red: 255, green: 59, blue: 48),
        getColorFrom(red: 255, green: 149, blue: 0),
        getColorFrom(red: 255, green: 204, blue: 0),
        getColorFrom(red: 76, green: 217, blue: 100),
        getColorFrom(red: 90, green: 200, blue: 250),
        getColorFrom(red: 0, green: 122, blue: 255),
        getColorFrom(red: 88, green: 86, blue: 214),
        getColorFrom(red: 255, green: 45, blue: 85)
    ]
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    weak var inspectorMenuController: InspectorMenuController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Color"
        
        view.backgroundColor = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        
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
        collectionView.register(InspectorColorViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InspectorColorViewCell
        let color = colors[indexPath.row]
        cell.set(for: color)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selected = self.inspectorMenuController?.selection?.first else {
            fatalError("no selected")
        }
        
        selected.inspectableChangeFillColor(from: (selected as! UIView).backgroundColor!, toColor: colors[indexPath.row], recordedIn: inspectorMenuController!.designViewController!.designView.designUndoManager)
    }

}

class InspectorColorViewCell: UICollectionViewCell {
    
    weak var inspectorMenuController: InspectorMenuController? = nil
    var colorContainerView: UIView? = nil
    var circleView: UIView? = nil
    
    func set(for color: UIColor) {
        if colorContainerView == nil {
            colorContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            addSubview(colorContainerView!)
            colorContainerView!.backgroundColor = .white
            colorContainerView!.layer.cornerRadius = 16
            colorContainerView!.clipsToBounds = true
            
            circleView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            colorContainerView!.addSubview(circleView!)
            circleView!.center = colorContainerView!.center
            circleView!.layer.cornerRadius = 20
            circleView!.layer.borderColor = UIColor.lightGray.cgColor
            circleView!.layer.borderWidth = 1
            circleView!.clipsToBounds = true
        }
        
        circleView!.backgroundColor = color
    }
    
}
