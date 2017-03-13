//
//  LoginViewController.swift
//  GChat
//
//  Created by Jubril Oyesiji on 3/10/17.
//  Copyright © 2017 Jubril Oyesiji. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseAuth
class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate  {
    
    @IBOutlet weak var anonymousButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        GIDSignIn.sharedInstance().clientID = "127803739780-8esa0u9remefrvphsci1a3mslusdp9h9.apps.googleusercontent.com"
        
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FIRAuth.auth()?.addStateDidChangeListener({(auth:FIRAuth, user:FIRUser?) in
            if user != nil {
                Helper.helper.switchToNavigationController();
            }else{
                print("Unauthorized")
            }
        
        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAnonymous(_ sender: Any) {
        Helper.helper.loginAnonymous();
    }
    @IBAction func login(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut();
        GIDSignIn.sharedInstance().signIn();
      
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("####This is disconnected");
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print(user.authentication)
        Helper.helper.logInWithGoogle(authentication: user.authentication)
        
    }
    
}


