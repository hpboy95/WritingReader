//
//  TextEditViewController.swift
//  WritingReader
//
//  Created by Hezekiah Valdez on 11/2/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//

import UIKit

class TextEditViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //Class Variables
    var convertedText = ""
    var fullText = ""
    var numberString = "1"
    var lineNumber = 1
    let sizes = [12, 14, 16, 18, 20]
    
    //View Objects
    @IBOutlet weak var textColorLabel: UILabel!
    @IBOutlet weak var textFontLabel: UITextField!
    @IBOutlet weak var lineNumberText: UITextView!
    @IBOutlet weak var ocrText: UITextView!
    @IBOutlet weak var sizePicker: UIPickerView!
    
    //Ensure that you create all necessary resources here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Edit the view and feel of each of the UI objects
        textColorLabel.layer.masksToBounds = true
        textColorLabel.layer.cornerRadius = 10
        
        textFontLabel.delegate = self
        textFontLabel.borderStyle = .roundedRect
        textFontLabel.layer.masksToBounds = true
        textFontLabel.layer.cornerRadius = 10
        textFontLabel.allowsEditingTextAttributes = false
        textFontLabel.backgroundColor = UIColor.white
        
        lineNumberText.delegate = self
        lineNumberText.isEditable = false
        lineNumberText.showsVerticalScrollIndicator = false
        lineNumberText.showsHorizontalScrollIndicator = false
        lineNumberText.font = UIFont.systemFont(ofSize: 16)
        
        ocrText.delegate = self
        ocrText.text = convertedText
        ocrText.font = UIFont.systemFont(ofSize: 16)
        
        sizePicker.translatesAutoresizingMaskIntoConstraints = false
        sizePicker.delegate = self
        sizePicker.dataSource = self
        sizePicker.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sizes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(sizes[row])
    }
    
    //Ensure that you delete any unused resources here
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Ensure that both editors scroll together uniformly
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //ensure the left scrolls with the right
        if scrollView == self.lineNumberText {
            self.ocrText.contentOffset = self.lineNumberText.contentOffset
        }
        //ensure the right scrolls with the left
        else if scrollView == self.ocrText {
            self.lineNumberText.contentOffset = self.ocrText.contentOffset
        }
    }
    
    //Ensure that the line number updates with the text
    func textViewDidChange(_ textView: UITextView) {
        lineNumber = 1
        fullText = textView.text!
        //Cycle through the text looking for newline characters
        for text in fullText.characters{
            if text == "\n" {
                lineNumber = lineNumber + 1
                numberString = ""
                //Increment the line number for each found newline character
                for i in 1 ... lineNumber {
                    numberString = numberString + "\(i)\n"
                }
            }
        }
        lineNumberText.text = numberString
    }
    
    //Ensure that the using the size picker auto updates view and then hides
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ocrText.font = UIFont.systemFont(ofSize: CGFloat(sizes[row]))
        lineNumberText.font = UIFont.systemFont(ofSize: CGFloat(sizes[row]))
        textFontLabel.text = String(sizes[row])
        sizePicker.isHidden = true
    }
    
    //Prevent testField from being editable and enable selection functionality
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        sizePicker.isHidden = false
        return false
    }
    
    //RPC recieving function
    func setEditingString(str: String){
        self.convertedText = str
    }
    
}
