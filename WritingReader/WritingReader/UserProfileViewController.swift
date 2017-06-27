//
//  UserProfileViewController.swift
//  WritingReader
//
//  Created by Guillermo Colin on 6/1/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        userLoggedIn()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var myLabel: UILabel!
    var ref:FIRDatabaseReference!
    
    
    func userLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(manageLogout), with: nil, afterDelay: 0)
        }
        else{
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.myLabel.text = dictionary["first name"] as? String
                }
                
            }, withCancel: nil)
            
        }
    }
    
    func manageLogout(){
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logoutError{
            print(logoutError)
        }
        
        let controller = ViewController()
        present(controller, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
