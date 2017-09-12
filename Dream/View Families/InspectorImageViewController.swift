//
//  InspectorImageViewController.swift
//  Dream
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class InspectorImageViewController: InspectorViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Image"
        view.backgroundColor = Dream.Colors.inspectorLightGray
        setForNoImage()
    }
    
    func setForNoImage() {
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        let photosButton = LargeRoundedUIButton()
        photosButton.setTitle("Photos", for: .normal)
        stackView.addArrangedSubview(photosButton)
        photosButton.addTarget(self, action: #selector(didTapPhotos), for: .touchUpInside)
        
        let cameraButton = LargeRoundedUIButton()
        cameraButton.setTitle("Camera", for: .normal)
        stackView.addArrangedSubview(cameraButton)
        cameraButton.addTarget(self, action: #selector(didTapCamera), for: .touchUpInside)
    }
    
    @objc func didTapPhotos() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func didTapCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        guard let selected = self.inspectorMenuController?.selection?.first else {
            fatalError("no selected")
        }
        
        guard let selectedAsUIView = selected as? UIView else {
            fatalError("Selected is not a UIView")
        }
        
        let imageView = UIImageView(image: image)
        selectedAsUIView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(selectedAsUIView)
            make.center.equalTo(selectedAsUIView)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

class LargeRoundedUIButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.45 : 1
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setTitleColor(tintColor, for: .normal)
        layer.cornerRadius = 16
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
