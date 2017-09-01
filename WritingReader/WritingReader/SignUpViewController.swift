//
//  SignUpViewController.swift
//  WritingReader
//
//  Created by Guillermo Colin on 5/31/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {                       // Do any additional setup after loading the view.
        super.viewDidLoad()

        self.confEmailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.confPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.ref = FIRDatabase.database().reference()
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
    }

    override func didReceiveMemoryWarning() {           // Dispose of any resources that can be recreated.
        super.didReceiveMemoryWarning()

    }
    
    override func viewDidLayoutSubviews() {
        //scrollView.contentSize = CGSize(width: 375, height: 1500)
    }
    
    //  Instantiate the reference to our database.
    var ref:FIRDatabaseReference!
    
    //  Instantiate UI components used.
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var confEmailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confPasswordTextField: UITextField!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //  ScrollView to adjust the view when typing requires it.
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var innerView: UIView!
    
    //  Sign up user if the form is filled out correctly.
    @IBAction func SignUp(_ sender: UIButton) {
        
        if(credentialsConfirmed()){         //  Store basic user's info in the database, once credentials are confirmed.
            registerUser(fNameTF: firstNameTextField, lNameTF: lastNameTextField, emailTF: emailTextField, passwordTF: passwordTextField, actInd: activityIndicator)

        }
        
    }
    
    //  Do black text while user is editing fields that need to be confirmed (email/password).
    func textFieldDidChange(_ textField: UITextField) {
        
        let blackText:UIColor = UIColor.black
        
        textField.textColor = blackText
        
    }
    
    //  Check if passwords match.
    func fieldsMatch(field1: String, field2: String) -> Bool{
        
        var matches:Bool = false
        
        if(field1 == field2){
            matches = true
        }
        
        return matches
        
    }

    //  Change color of TextField to alert of mistyped email/password.
    func changeTextFieldColor(textField: UITextField){
        
        let redText:UIColor = UIColor.red
        
        textField.textColor = redText
        
    }
    
    //  Check if email/password credentials were confirmed.
    func credentialsConfirmed() -> Bool{
        
        var canSignUp:Bool = false;
        
        let emailMatches:Bool = fieldsMatch(field1: emailTextField.text!, field2: confEmailTextField.text!)
        
        let passwordMatches:Bool = fieldsMatch(field1: passwordTextField.text!, field2: confPasswordTextField.text!)
        
        if(!emailMatches){
            changeTextFieldColor(textField: confEmailTextField)
        }
        if(!passwordMatches){
            changeTextFieldColor(textField: confPasswordTextField)
        }
        if(emailMatches && passwordMatches){
            canSignUp = true
        }

        return canSignUp
        
    }
    
    //  Register user, assuming data was filled correctly. 
    func registerUser(fNameTF: UITextField, lNameTF: UITextField, emailTF:UITextField, passwordTF: UITextField, actInd: UIActivityIndicatorView){
        
        //actInd.isHidden = false
        
        actInd.startAnimating()
        
        guard let name = fNameTF.text, let lastName = lNameTF.text else{
            print("Invalid name")
            return
        }
        
        guard let email = emailTF.text, let password = passwordTF.text else{
            print("\nLog in credentials were not valid\n")
            return
        }
        
        //  Create and register user's profile in the database.
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
         if error != nil{                           //  Error while registering the user.
            actInd.stopAnimating()
            actInd.isHidden = true
         print(error!.localizedDescription)
         }
            
         else{                                      //  User successfully registered.
         print("\nUser succesfully registered!!!")
            
            guard let uid = user?.uid else{
                return
            }
            
            let usersReference = self.ref.child("Users").child(uid)
            let values = ["First_Name": name, "Last_Name": lastName,"Email": email]

            usersReference.updateChildValues(values, withCompletionBlock: {
                (error, ref) in
                
                if(error !=  nil){                  //  Error while saving user's info.
                    print(error.debugDescription)
                }
                else{                               //  User's basic info succesfully updated.
                    print("\nUser info saved successfully\n")
                    
                    actInd.stopAnimating()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "LogInView")
                    self.present(controller, animated: true, completion: nil)
                }
            })
         }
         })
    
    }
    
    
    //  Function to go to the next UITextField whenver the Next button is available on the keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Increment the tag of UITextField by 1.
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        }
        else {
            // Remove keyboard.
            textField.resignFirstResponder()
        }
        
        return false
        
    }
    
    //  Function to readjust the view if the keyboard covers the current UITextField.
    func textFieldDidBeginEditing(_ textField: UITextField) {

        //  Move the innerView a little higher so that the textField can be seen.
        switch textField {
            
        case passwordTextField:
            
            self.scrollView.setContentOffset(CGPoint(x:0, y:250) , animated: true)
            break
            
        case confPasswordTextField:
            
            self.scrollView.setContentOffset(CGPoint(x:0, y:250) , animated: true)
            break
            
        default:
            break
        }
    }
    
    
    //  Function to readjust the view if the user ends editing the current UITextField.
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
    
}
