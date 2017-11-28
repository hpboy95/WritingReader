//
//  SettingsViewController.swift
//  WritingReader
//
//  Created by Guillermo Colin on 11/28/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let defaults:UserDefaults = UserDefaults.standard
    
    @IBOutlet weak var `switch`: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.topItem?.title = ""
        title = "Settings"
    }
    
    @IBAction func switchButton(_ sender: UISwitch) {
        if sender.isOn == false{
            defaults.set(false, forKey: "SpellChecker")
            print("Switch button turned off")
        }else{
            defaults.set(true, forKey: "SpellChecker")
            print("Switch button turned on")
        }
    }


}
