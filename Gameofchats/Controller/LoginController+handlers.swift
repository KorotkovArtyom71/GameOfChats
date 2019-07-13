//
//  LoginController+handlers.swift
//  Gameofchats
//
//  Created by artyom korotkov on 2/8/19.
//  Copyright © 2019 artyom korotkov. All rights reserved.
//

import UIKit
import Firebase


extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error)
                return
            }
            
            print("Coooooool")
            
            guard let uid = user?.user.uid else {
                return
            }
            
            //succefully authentificated user
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let profileImage = self.profileImageView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
                
                storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in

                    print("Ohoooooooo")
                    if err != nil {
                        print(err)
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        
                        guard let url = url else { return }
                        let values = ["name": name, "email": email, "profileImageUrl": url.absoluteString, "id": uid]
                        
                        self.registerUserIntoDatabase(uid: uid, values: values as [String : AnyObject])
                    })

                })
            }
        })
    }
    
    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(uid)

        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print("ERRRRRROR")
                return
            }
            
            let user = User(dictionary: values)
            self.messagesController?.setupNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }

    
    @objc func handleSelectProfileImageView() {
        print(123)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
