//
//  RegistrViewController.swift
//  TestRouteTracker
//
//  Created by admin on 14.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RegistrViewController: UIViewController, Storyboarded {
    //MARK: - IBOutlet
    @IBOutlet private var scroolView: UIScrollView!
    @IBOutlet private var passwordTextFild: UITextField!
    @IBOutlet private var loginTextFild: UITextField!
    @IBOutlet private var registrButtonRX: UIButton!
    //MARK: - Properties
    private let realmService = RealmUserData()
    weak var coordinator: MainCoordinators?
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRegistrButton()
        configureKeyBoard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotifications()
    }
    //MARK: - Action
    @IBAction func registrButton(_ sender: Any) {
        guard let login = loginTextFild.text, let password = passwordTextFild.text else {return}
        if !login.isEmpty , !password.isEmpty {
            realmService.saveUserData(login: login, password: password)
            messageAlert(title: "Отлично", message: "Вы успешно зарегестрировались")
        } else {
            messageError()
        }
    }
    //MARK: - Private Functions
    private func configureKeyBoard() {
        let hideKeyboardGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(hideKeyboard))
        scroolView?.addGestureRecognizer(hideKeyboardGesture)
        
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
    
    private func configureRegistrButton() {
        Observable.combineLatest(loginTextFild.rx.text, passwordTextFild.rx.text).map {login, password in
            return !(login ?? "").isEmpty && (password ?? "").count >= 3
        }.bind { [weak registrButtonRX] input in
            registrButtonRX?.isEnabled = input
        }
    }
    
    private func messageAlert(title: String, message: String) {
        loginTextFild.text = nil
        passwordTextFild.text = nil
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: actionAlert)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func actionAlert(action: UIAlertAction! = nil) {
        UserDefaults.standard.set(true, forKey: "isLogin")
        coordinator?.goMainVC()
    }
    
    private func messageError() {
        let ac = UIAlertController(title: "Ошибка", message: "По пробовать заново", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
    //MARK: - Functions
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
