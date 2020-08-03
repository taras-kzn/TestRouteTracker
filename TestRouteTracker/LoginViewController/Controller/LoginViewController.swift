//
//  LoginViewController.swift
//  TestRouteTracker
//
//  Created by admin on 14.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController, Storyboarded {
    //MARK: - IBOutlet
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var loginTextFild: UITextField!
    @IBOutlet private var passwordTextFild: UITextField!
    @IBOutlet private var loginButton: UIButton!
    //MARK: - Properties
    private var realmService = RealmUserData()
    private var users = User()
    var coordinator: MainCoordinators?
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLoginBinding()
        configureKeyBoard()
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UserDefaults.standard.bool(forKey: "isLogin") {
            coordinator?.goMainVC()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotifications()
    }
    //MARK: - Actions
    @IBAction func loginActionButton(_ sender: Any) {
        guard let login = loginTextFild.text?.lowercased(), let password = passwordTextFild.text?.lowercased() else {return}

        loadUsers(login: login)

        if !users.login.isEmpty, !users.password.isEmpty {
            if login == users.login.lowercased() && password == users.password.lowercased() {
                UserDefaults.standard.set(true, forKey: "isLogin")
                coordinator?.goMainVC()
            } else {
                errorAuthorization()
            }
        } else {
            errorAuthorization()
        }
    }
    
    @IBAction func registerButton(_ sender: Any) {
        coordinator?.goRegistrVC()
    }
    //MARK: - Private Functions
    private func configureKeyBoard(){
        let hideKeyboardGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(hideKeyboard))
        scrollView?.addGestureRecognizer(hideKeyboardGesture)
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (nc) in
            self.view.frame.origin.y = -210
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (nc) in
            self.view.frame.origin.y = 0.0
        }
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureLoginBinding() {
        Observable.combineLatest(loginTextFild.rx.text, passwordTextFild.rx.text).map { login, password in
            return !(login ?? "").isEmpty && (password ?? "").count >= 3
        }.bind {
            [weak loginButton] inputFilled in
            loginButton?.isEnabled = inputFilled
        }
    }
    
    private func loadUsers(login: String) {
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
    
    private func errorAuthorization() {
        loginTextFild.text = nil
        passwordTextFild.text = nil
        let ac = UIAlertController(title: "Ошибка", message: "Вы ввели неправильно логин или пароль", preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать заново", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    //MARK: - Functions
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
        scrollView?.scrollIndicatorInsets = contentInsets
    }
    
    @objc func hideKeyboard() {
        self.scrollView?.endEditing(true)
    }
}
