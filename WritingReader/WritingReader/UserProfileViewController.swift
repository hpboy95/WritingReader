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

class UserProfileViewController: UIViewController{

    //  Mark: - Properties
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var labelResults: UITextField!
    
    @IBOutlet weak var faceResults: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var processingView: UIView!
    
    
    //  Mark: - Variables
    var ref:DatabaseReference!

    let session = URLSession.shared
    
    var googleAPIKey = "AIzaSyBv-oL8NqvL0BpGWle979PufOOaF3ROz54"
    
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    var imgUUID:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        userLoggedIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}

/// Image processing

extension UserProfileViewController {
    
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            self.imageView.isHidden = true
            self.labelResults.isHidden = false
            self.faceResults.isHidden = true
            self.faceResults.text = ""
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]
                
                // Get converted text
                let labelAnnotations: JSON = responses["textAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    var labelResultsText:String = "OCR Result: "
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
                    self.labelResults.text = labelResultsText
                } else {
                    self.labelResults.text = "Unrecognizable"
                }
                //test-start
                self.processingView.isHidden = true
                //test-end
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
                            self.ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("Images_Recognized").child(self.imgUUID).updateChildValues(["Text": self.labelResults.text ?? "Unrecognizable"])
                        }
                    })
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                }
            })
        }
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

