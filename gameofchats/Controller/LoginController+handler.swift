//
//  LoginController+handler.swift
//  gameofchats
//
//  Created by zippo1908 on 2018/1/2.
//  Copyright © 2018年 zippo1908. All rights reserved.
//

import Foundation
import UIKit
extension LoginController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @objc func handleSelectProfileImageView(){
       let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info["UIImagePickerControllerOriginalImage"]{
            print(originalImage)
            print(info)}
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }

}
