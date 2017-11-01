//
//  SignInViewController.swift
//  WritingReader
//
//  Created by Hezekiah Valdez on 1/23/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//  Anthony and Guillermo (test for pushing)

import UIKit
import Firebase
import FirebaseAuth


class SignInViewController: UIViewController {
    
    // MARK: - Properties
    
    var ref:DatabaseReference!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        registerNotifications()
        setupGestureRecognizers()
        
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    //  Perform the sign in with the given login credentials.
    @IBAction func signIn(_ sender: UIButton) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {(user, error) in
            
            //  Invalid Log in
            if error != nil{
                print("\nUSER NOT REGISTERED\n")
                
                let alert = UIAlertController(title: "Invalid Credentials", message: "Double check your email and password!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            //  Successful Log in.
            }else{
                print("\n\nSuccessfully Logged In...Welcome\n")
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                //let controller = storyBoard.instantiateViewController(withIdentifier: "userprofileVC")
                let controller = storyBoard.instantiateViewController(withIdentifier: "HomeScreenVC")
                self.present(controller, animated: true, completion: nil)
                
            }
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.activityIndicator.stopAnimating()
        })
        
    }
    
    //  Perform transition to the sign up view (signupVC) for the user to register.
    @IBAction func signUp(_ sender: UIButton) {
        
        let storyBoard = UIStoryboard(name:"Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "signupVC")
        self.present(controller, animated: false, completion: nil)
        
    }
    
    
    func registerNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(){
        
        loginLabelTopConstraint.constant = -70
        UIView.animate(withDuration: 1) {
            self.loginLabel.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(){
        loginLabelTopConstraint.constant = 8
        loginLabel.isHidden = false
        UIView.animate(withDuration: 1){
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func setupGestureRecognizers() {
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(hidekeyboard))
        view.addGestureRecognizer(backgroundTapGesture)
    }
    
    func hidekeyboard(){
        view.endEditing(true)
    }
}





