//
//  LoginViewController.swift
//  TestRouteTracker
//
//  Created by admin on 14.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var loginTextFild: UITextField!
    @IBOutlet var passwordTextFild: UITextField!
    
    var realmService = RealmUserData()
    var users = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(hideKeyboard))
        
        scrollView?.addGestureRecognizer(hideKeyboardGesture)

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
    
    @IBAction func loginActionButton(_ sender: Any) {
        guard let login = loginTextFild.text, let password = passwordTextFild.text else {return}
        loadUsers(login: login)
        if login == users.login && password == users.password {
        } else {
            errorAuthorization()
        }
    }
    
    @IBAction func registrButton(_ sender: Any) {
    }
    
    func loadUsers(login: String) {
        let user = User()
        do {
            let realm = try Realm()
            let usersRealm = realm.objects(User.self).filter("login == %@", login)
            for i in usersRealm {
                user.login = i.login
                user.password = i.password
            }
            self.users = user
        } catch {
            print(error)
        }
    }
    
    func errorAuthorization() {
        loginTextFild.text = nil
        passwordTextFild.text = nil
        let ac = UIAlertController(title: "Ошибка", message: "Вы ввели неправильно логин или пароль", preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать заново", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        
        self.scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView?.contentInset = contentInsets
    }
    
    @objc func hideKeyboard() {
        self.scrollView?.endEditing(true)
    }
}
