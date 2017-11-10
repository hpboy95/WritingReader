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
        navigationController?.navigationBar.backItem?.title = ""
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.title = "Home Screen"
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
    
    @IBAction func cameraRollButton(_ sender: UIButton) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .overFullScreen

        present(imagePicker, animated: true, completion: nil)
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        chosenImage = originalImage

        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "CameraRollSegue", sender: nil)
        })
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


