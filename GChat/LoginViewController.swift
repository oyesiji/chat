//
//  LoginViewController.swift
//  GChat
//
//  Created by Jubril Oyesiji on 3/10/17.
//  Copyright © 2017 Jubril Oyesiji. All rights reserved.
//

import UIKit
import  FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var anonymousButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAnonymous(_ sender: Any) {
        Helper.helper.loginAnonymous();
    }
    @IBAction func login(_ sender: Any) {
    }
    
}


