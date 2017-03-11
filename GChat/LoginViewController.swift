//
//  LoginViewController.swift
//  GChat
//
//  Created by Jubril Oyesiji on 3/10/17.
//  Copyright © 2017 Jubril Oyesiji. All rights reserved.
//

import UIKit

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
        print("Login Anonym")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVc = storyboard.instantiateViewController(withIdentifier: "navigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVc
        
        
        
    }
    @IBAction func login(_ sender: Any) {
    }
    
}


