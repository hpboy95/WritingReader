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
import FirebaseStorage
import SwiftyJSON


class UserProfileViewController: UIViewController, UITextFieldDelegate, detectedTextDelegate{

    //  Mark: - Properties
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var convertedText: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func sharePressed(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [convertedText.text], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    //  Mark: - Variables
    var ref:DatabaseReference!

    let session = URLSession.shared
    
    var googleAPIKey = "AIzaSyBv-oL8NqvL0BpGWle979PufOOaF3ROz54"
    
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    var chosenImage = UIImage()
    
    var imgUUID:String!
    
    var originalTextEdited:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        userLoggedIn()
        
        self.convertedText.layer.borderWidth = 0.5
        self.convertedText.layer.borderColor = UIColor.lightGray.cgColor
        self.convertedText.backgroundColor = UIColor.lightGray
        self.convertedText.allowsEditingTextAttributes = false
        self.convertedText.delegate = self
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        self.activityIndicator.transform = transform
        self.activityIndicator.center = self.view.center
        
        imageView.image = chosenImage
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
        title = "OCR Results"
    }
    
    func userLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(manageLogout), with: nil, afterDelay: 0)
        }
        else{
            //  Do anything if user logs in successfully.
        }
    }
    
    func manageLogout(){
        do{
            try Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
        
        let controller = SignInViewController()
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        
        if originalTextEdited == true {
            save(text: convertedText.text!)
        }else{
            storeImageWithRecognizedText(image: chosenImage)
        }
    }
    
    
    //This turns the UITextfield into a button
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.performSegue(withIdentifier: "TextEditSegue", sender: self)
        return false
    }
    
    //Pass text data to the text editing screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TextEditViewController{
            dest.setEditingString(str: self.convertedText.text!)
        }
        
        if segue.identifier == "TextEditSegue"{
            if let dest = segue.destination as? TextEditViewController{
                dest.delegate = self
            }
        }
    }
    
    internal func userEditedOriginalYieldedText(_ textChanged: Bool, _ text: String) {
        
        if text.isEmpty == false{
            originalTextEdited = textChanged
            convertedText.text = text
        }
    }
}

/// Image processing
extension UserProfileViewController {
    
    func analyzeResults(_ dataToParse: Data) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            
            // Use SwiftyJSON to parse results
            let json = try! JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            //self.imageView.isHidden = true
            self.convertedText.isHidden = false
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                self.convertedText.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]
                
                // Get converted text
                let labelAnnotations: JSON = responses["textAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    var labelResultsText:String = ""
                    for index in 0..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        if labelAnnotations[index]["locale"].exists() {
                            labels.append(label)
                        }
                        
                    }
                    for label in labels {
                        // if it's not the last item add a comma
                        if labels[labels.count - 1] != label {
                            labelResultsText += "\(label), "
                        } else {
                            labelResultsText += "\(label)"
                        }
                    }
                    self.convertedText.text = labelResultsText
                } else {
                    self.convertedText.text = "Unrecognizable"
                }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                DispatchQueue.main.async {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        })
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }

    func storeImageWithRecognizedText(image: UIImage){
        imgUUID = NSUUID().uuidString
        
        let storage = Storage.storage().reference().child("picture").child("\(imgUUID!).png")
        
        if let uploadData = UIImagePNGRepresentation(image){
            storage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    
                    guard let uid = Auth.auth().currentUser?.uid else{
                        return
                    }
                    
                    let userReference = self.ref.child("Users").child(uid).child("Images_Recognized").child(self.imgUUID)
                    
                    userReference.updateChildValues(["ImageURL": imageURL], withCompletionBlock:{ (error, ref) in
                        if (error != nil){
                            print(error?.localizedDescription ?? "Error saving user data")
                        }
                        else{
                            print("Picture successfully uploaded!")
                            self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("Images_Recognized").child(self.imgUUID).updateChildValues(["Text": self.convertedText.text ?? "Unrecognizable"])
                        }
                    })
                }
            })
        }
    }
    
    func save(text:String){
        self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("Images_Recognized").child(self.imgUUID).updateChildValues(["Text": self.convertedText.text ?? "Unrecognizable"])
    }
}


/// Networking

extension UserProfileViewController {
    
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Create our request URL
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request)}
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
            
                return
            }
           
            self.analyzeResults(data)
        }
        
        task.resume()
    }
}



// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


