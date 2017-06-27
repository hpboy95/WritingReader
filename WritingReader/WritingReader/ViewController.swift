//
//  ViewController.swift
//  WritingReader
//
//  Created by Hezekiah Valdez on 1/23/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//  Anthony and Guillermo (test for pushing)

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //  Instantiate the reference to our database.
    var ref:FIRDatabaseReference!
    
    //  Instantiate UI components used.
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    //  Perform the sign in with the given login credentials.
    @IBAction func signIn(_ sender: UIButton) {
        
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {(user, error) in
            
            if error != nil{                                    //  If invalid or impossible login, then alert user.
                print("\nUSER NOT REGISTERED\n")
                
                let alert = UIAlertController(title: "Invalid Credentials", message: "Double check your email and password!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }else{                                              //  Successful login, take user to the userprofileVC.
                print("\n\nSuccessfully Logged In...Welcome\n")
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyBoard.instantiateViewController(withIdentifier: "userprofileVC")
                self.present(controller, animated: true, completion: nil)
            }
        })
        
    }
    
    //  Perform transition to the sign up view (signupVC) for the user to register.
    @IBAction func signUp(_ sender: UIButton) {
        
        let storyBoard = UIStoryboard(name:"Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "signupVC")
        self.present(controller, animated: false, completion: nil)
        
    }
    
    
    
}





