//
//  ForgotPasswordViewController.swift
//  WritingReader
//
//  Created by Guillermo Colin on 11/21/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.clipsToBounds = true
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.backItem?.title = ""
        title = "Forgot your password?"
    }
    
    
    @IBAction func resetPasswordButton(_ sender: UIButton) {
        
        //  Indicate an operation is taking place behind the scenes.
        activityIndicator.startAnimating()
        
        //  Ignore any tapping that the user makes while this process occurs.
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        guard let email:String = emailTextField.text else{
            return
        }
        
        //  Send a password resent using Firebase's services.
        Auth.auth().sendPasswordReset(withEmail: email, completion: { error in
            
            if error != nil{
                
                //  Alert the user that an email has been sent to reset password.
                let alert = UIAlertController(title:"Ooops!", message: "Something went wrong...please try again later.", preferredStyle: .alert)
                
                //  Add an OK button to dismiss it.
                alert.addAction(UIAlertAction(title:"OK", style: .cancel,handler: nil))
                
                //  Present it.
                self.present(alert, animated: true, completion: nil)
                
                //  Stop animating the activityIndicator, the process has finished.
                self.activityIndicator.stopAnimating()
                
                //  Register any tapping that the user makes when this process finishes.
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            else{
                
                //  Alert the user that an email has been sent to reset password.
                let alert = UIAlertController(title:"Check your email!", message: "Look for an email from us to reset your password.", preferredStyle: .alert)
                
                //  Add an OK button to take the user back to the LogInView
                alert.addAction(UIAlertAction(title:"OK", style: .cancel){ action in
                    
                    /*  Pop View Controller. */
                    _ = self.navigationController?.popViewController(animated: true)
                })
                
                //  Present it.
                self.present(alert, animated: true, completion: nil)
                
                //  Stop animating the activityIndicator, the process has finished.
                self.activityIndicator.stopAnimating()
                
                //  Register any tapping that the user makes when this process finishes.
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            
        })
    }

}
