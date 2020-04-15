//
//  RegistrViewController.swift
//  TestRouteTracker
//
//  Created by admin on 14.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit

class RegistrViewController: UIViewController, Storyboarded {

    @IBOutlet var scroolView: UIScrollView!
    @IBOutlet var passwordTextFild: UITextField!
    @IBOutlet var loginTextFild: UITextField!
    
    let realmService = RealmUserData()
    var coordinator: MainCoordinators?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(hideKeyboard))
        
        scroolView?.addGestureRecognizer(hideKeyboardGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWasShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillBeHidden(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
              
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @IBAction func registrButton(_ sender: Any) {
        guard let login = loginTextFild.text, let password = passwordTextFild.text else {return}
        if !login.isEmpty , !password.isEmpty {
            realmService.saveUserData(login: login, password: password)
            messageAlert(title: "Отлично", message: "Вы успешно зарегестрировались")
        } else {
            messageError()
        }
    }
    
    func messageAlert(title: String, message: String) {
        loginTextFild.text = nil
        passwordTextFild.text = nil
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: actionAlert)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func actionAlert(action: UIAlertAction! = nil) {
        coordinator?.start()
    }
    
    func messageError() {
        let ac = UIAlertController(title: "Ошибка", message: "По пробовать заново", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        
        self.scroolView?.contentInset = contentInsets
        scroolView?.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scroolView?.contentInset = contentInsets
    }
    
    @objc func hideKeyboard() {
        self.scroolView?.endEditing(true)
    }
}
