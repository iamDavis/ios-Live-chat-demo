//
//  ViewController.swift
//  gameofchats
//
//  Created by zippo1908 on 2017/12/23.
//  Copyright © 2017年 zippo1908. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    @objc func handleLogout(){
    let loginController = LoginController()
    present(loginController, animated: true, completion: nil)
    }
    
   
    
}

