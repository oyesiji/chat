//
//  Helper.swift
//  GChat
//
//  Created by Jubril Oyesiji on 3/10/17.
//  Copyright © 2017 Jubril Oyesiji. All rights reserved.
//

import Foundation

import FirebaseAuth
import UIKit
import Firebase
import GoogleSignIn

class Helper {
    static let helper = Helper()
    
    
    func loginAnonymous() {
        print("Login Anonym")
        FIRAuth.auth()?.signInAnonymously() { (user, error) in
            if error == nil {
                print("User Id : \(user?.uid)");
            }else{
                print(error?.localizedDescription )
                return
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVc = storyboard.instantiateViewController(withIdentifier: "navigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVc
        
        
        
    }
    
    
    func logInWithGoogle(authentication: GIDAuthentication){
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential){ (user, error) in
            if error == nil {
                print("User Id : \(user?.uid)");
                print("User Email : \(user?.email)");
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let naviVc = storyboard.instantiateViewController(withIdentifier: "navigationVC") as! UINavigationController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = naviVc
                
            }else{
                print(error?.localizedDescription )
                return
            }
        }

        
    }
    
}
