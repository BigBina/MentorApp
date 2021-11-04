---
attachments: [Screen Shot 2021-10-14 at 1.46.34 AM.png]
title: Picture-Upload
created: '2021-10-13T07:40:16.633Z'
modified: '2021-11-01T19:48:12.057Z'
---

# Picture-Upload

## Profile Pictures

### Xcode Privacy

![Image](@attachment/Screen Shot 2021-10-14 at 1.46.34 AM.png)



## [<mark>Storing Photos in Firebase</mark>](https://firebase.google.com/docs/storage/ios/start)
There is a section where I talk about the Firebase storage in: [Firebase](@note/Firebase)
Quick YouTube Reference: [<mark>Upload Image To Firebase</mark>](https://www.youtube.com/watch?v=aQXlivV4CDI)


## Take Pictues with a Camera and Uploading Photos from Photo Library

YouTube Reference: [<mark>Taking or Choosing Pictures</mark>](https://www.youtube.com/watch?v=CftU33ZNjAU)

This function is called when the profile icon is pressed. It presents the action sheet that gives the option to select a photo from the library or take a photo with the camera and directly upload it.
```swift
extension LocationView: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a photo?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler:{ [weak self] _ in
            self?.presentCamera()
        } ))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler:{ [weak self] _ in
            // so that a memory retention loop isn't created. And self becomes optional since its weak.
            self?.presentPhotoPicker()
            
        }))

        present(actionSheet, animated: true)
    }
```

These functions allows you editing and crop the photos that a user post. This helps keep all of the photos the same size.
``` swift
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
```
```swift
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            image = selectedImage
            self.imageView.image = selectedImage
        }
        
    }
}
```
