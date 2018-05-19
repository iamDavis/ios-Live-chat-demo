//
//  LoginController+handler.swift
//  gameofchats
//
//  Created by zeyu deng on 2017/12/26.
//  Copyright © 2017年 zeyu deng. All rights reserved.
//

import UIKit
import Firebase
extension LoginController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @objc func handleRegister(){
        guard let email = EmailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                print("Form is not vaild")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user: User?, Error) in
            if Error != nil {
                print(Error as Any)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            
            let storageReference = Storage.storage().reference().child("profile_images").child("\(imageName).j")
            
            if let profileImage = self.profileImageView.image,
                let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
            
            //    if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
            
           // if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
                storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error as Any)
                        return
                    }
                    if  let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabase(uid: uid , values: values as [String : AnyObject])
                        
                    }

                })
            }
            
        })
    }
    
    
    private func registerUserIntoDatabase(uid: String,values:[String:   AnyObject]){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let usersReference = ref.child("usrs").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: {(err, ref)
            in
            
            if err != nil {
                print(err as Any)
                return
            }
            print("Saved users successfully into FireDB")
            
      //      self.messageController?.fetchUserAndSetupNavBarTitle()
            self.messageController?.navigationItem.title = (values["name"] as! String)
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    @objc func handleSelectProfileImageView(){
       let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker : UIImage?
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{ selectedImageFromPicker = editedImage
            selectedImageFromPicker = editedImage
        }    else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
           selectedImageFromPicker = originalImage
    }
    
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
        }
    
    
}
