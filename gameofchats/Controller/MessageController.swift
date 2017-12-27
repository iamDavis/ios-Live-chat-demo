//
//  ViewController.swift
//  gameofchats
//
//  Created by zippo1908 on 2017/12/23.
//  Copyright © 2017年 zippo1908. All rights reserved.
//

import UIKit
import Firebase
class MessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLogin()
    }
    @objc func handleNewMessage(){
        let newMessageController = newMessagesController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    func checkIfUserIsLogin(){
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("usrs").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                    print("process finished")
                }
                
            }, withCancel: nil)
        }
    }
    
    @objc func handleLogout(){
        
        do {
            try Auth.auth().signOut()
        }   catch let logoutError{
            print(logoutError)
        }

    let loginController = LoginController()
    present(loginController, animated: true, completion: nil)
    }
}

