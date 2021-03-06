//
//  HomeScreenViewController.swift
//  WritingReader
//
//  Created by Guillermo Colin on 10/6/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class HomeScreenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Mark: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // Mark: - Variables
    var ref: DatabaseReference! = nil
    
    var imgs = [String]()
    
    let imagePicker = UIImagePickerController()
    
    var chosenImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        /*  Register nib files to use custom cells. */
        let nib = UINib(nibName: "HomeScreenCollectionViewCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "Cell")
        
        ref = Database.database().reference()
        
        getImages()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        selectedImage.isHidden = true
        
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
        navigationController?.title = "Home Screen"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutButton))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "BradleyHandITCTT-Bold",size: 17)!], for: .normal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsButton))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "BradleyHandITCTT-Bold",size: 17)!], for: .normal)
    }
    
    func getImages(){
        
        let userID:String = (Auth.auth().currentUser?.uid)!
        ref.child("Users").child(userID).child("Images_Recognized").observe(.value, with: { snapshot in
            if !snapshot.exists() {return}
            
            for childSnap in  snapshot.children.allObjects {
                let snap = childSnap as! DataSnapshot
                
                if let dict = snap.value as? [String: Any]{
                    let IMGURL = dict["ImageURL"] as! String
                    self.imgs.append(IMGURL)
                    print("found image: \(IMGURL)")
                    
                }
            }
            self.collectionView.reloadData()
            print("Tried reloading and size of imgs \(self.imgs.count)")
        })
    }
    
    @IBAction func libraryButton(_ sender: UIButton) {
        //Always ensure that the phone's camera is reachable
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            print("has photo library")
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            print("No photolibrary")
        }
    }
    
    @IBAction func cameraButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            print("has camera")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        else{
            print("no camera")
        }
    }
    
    @IBAction func ocrButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "CameraRollSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CameraRollSegue"{
            
            if let destination = segue.destination as? UserProfileViewController{
                
                let binaryImageData = destination.base64EncodeImage(chosenImage)
                destination.createRequest(with: binaryImageData)

                    // Send the chosen image and set it on the UserProfileViewController
                    if let image = self.chosenImage as UIImage! {
                        destination.chosenImage = image
                    }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject]!){
        selectedImage.image = image
        selectedImage.isHidden = false
        collectionView.isHidden = true
        
        chosenImage = image
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}


extension HomeScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HomeScreenCollectionViewCell
        
        if (imgs.count) > 0 {
            cell.image.loadIMG(URL_String: (imgs[indexPath.row]))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: 128) // Return any non-zero size here
    }
    
    
}

extension HomeScreenViewController{
    
    /*  Action exectuted when the Log Out button is pressed.    */
    func logOutButton() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
        
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                print("logOut() was called")

                
            } catch let error as NSError {
                print(error.localizedDescription)
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                _ = self.navigationController?.popViewController(animated: true)
                UIApplication.shared.endIgnoringInteractionEvents()
            }

        }

    }
    
    /*  Action executed when the Settings button is pressed.    */
    func settingsButton(){
        let storyBoard = UIStoryboard(name:"Main", bundle: nil)
        let VC = storyBoard.instantiateViewController(withIdentifier: "SettingsVC")
        navigationController?.pushViewController(VC, animated: true)
    }
}


