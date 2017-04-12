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


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var ref:FIRDatabaseReference!
    
    
    @IBAction func signIn(_ sender: UIButton) {
        ref.child("Email").setValue(emailTextField.text!)
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {(user, error) in
            
            if error != nil{
                print("\nUSER NOT REGISTERED\n")
            }else{
                print("\n\nSuccessfully Logged In...Welcome\n")
            }
        })
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if error != nil{
                print(error!.localizedDescription)
            }
            else{
                print("\nUser succesfully created!!!")
            }
        })
    }
    
    
    
}

