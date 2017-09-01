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
import SwiftyJSON

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

    
    // Test - Start
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    
    
    var googleAPIKey = "AIzaSyBv-oL8NqvL0BpGWle979PufOOaF3ROz54"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    @IBAction func pickImageButton(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            imageView.contentMode = .scaleAspectFit
//            imageView.isHidden = true // You could optionally display the image here by setting imageView.image = pickedImage
//            spinner.startAnimating()
//            faceResults.isHidden = true
//            labelResults.isHidden = true
//            
//            // Base64 encode the image and create the request
//            let binaryImageData = base64EncodeImage(pickedImage)
//            createRequest(with: binaryImageData)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Test - End
    
    
}
