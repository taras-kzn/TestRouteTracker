//
//  MainViewController.swift
//  TestRouteTracker
//
//  Created by admin on 15.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import Foundation


final class MainViewController: UIViewController, Storyboarded {
    //MARK: - IBOutlet
    @IBOutlet private var imageView: UIView!
    @IBOutlet private var imageViewSelfi: UIImageView!
    //MARK: - Properties
    weak var coordinator: MainCoordinators?
    private var imageSelfi: UIImage?
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configImage()
        loadImage()
        navigationItem.hidesBackButton = true
    }
    //MARK: - Actions
    @IBAction func tappedPicture(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("no camer")
            return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true)
    }
    
    @IBAction func actionMapsButton(_ sender: Any) {
        coordinator?.goMapsVC(image: imageSelfi)
    }
    
    @IBAction func backLoginButton(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLogin")
        coordinator?.start()
    }
    //MARK: - Functions
    private func configImage() {
        imageView.layer.cornerRadius = 20
        imageView.layer.shadowOpacity = 0.5
        imageViewSelfi.layer.cornerRadius = 15
        imageViewSelfi.layer.masksToBounds = true
    }
    
    private func saveImage(image: UIImage) {
        let image = image
        let imagedata = image.pngData()
        UserDefaults.standard.set(imagedata, forKey: "saveImage")
    }
    
    private func loadImage() {
        if let imageDta = UserDefaults.standard.object(forKey: "saveImage") as? Data {
            let image = UIImage(data: imageDta)
            imageViewSelfi.image = image
            imageSelfi = image
        } else {
            print("Нет фото по ключу saveImage")
        }
    }
}
//MARK: - NavigationControllerDelegate, ImagePickerControllerDelegate
extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("есть фото \(image)")
            saveImage(image: image)
            loadImage()
        } else {
            print("no image")
        }
        picker.dismiss(animated: true)
    }
}
