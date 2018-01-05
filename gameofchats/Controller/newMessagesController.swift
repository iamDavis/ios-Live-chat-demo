//
//  newMessagesController.swift
//  gameofchats
//
//  Created by zippo1908 on 2017/12/26.
//  Copyright © 2017年 zippo1908. All rights reserved.
//

import UIKit
import Firebase
class newMessagesController: UITableViewController {
    let cellID = "cellID"
    var usrs = [Usrs]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem (title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        fetchUsers()
        
}
    func fetchUsers() {
        let rootRef = Database.database().reference()
        let query = rootRef.child("usrs").queryOrdered(byChild: "name")
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let value = child.value as? NSDictionary {
                    let user = Usrs()
                    let name = value["name"] as? String ?? "Name not found"
                    let email = value["email"] as? String ?? "Email not found"
                    user.name = name
                    user.email = email
                 //   print(user.name, user.email)
                    
                    self.usrs.append(user)
                    
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
        }
    }
   @objc func handleCancel(){
        dismiss(animated: true , completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usrs.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // use a hack for nowe
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        let user = usrs[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
        
    }
}

class UserCell: UITableViewCell{
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(Coder:) has not been implemented")
    }
}
