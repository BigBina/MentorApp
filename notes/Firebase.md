---
attachments: [Screen Shot 2021-09-28 at 10.01.03 AM.png, Screen Shot 2021-09-28 at 11.02.11 AM.png]
title: Firebase
created: '2021-09-27T18:08:53.291Z'
modified: '2021-11-01T20:13:50.114Z'
---

# Firebase
## [<mark>Authentication</mark>](https://firebase.google.com/docs/auth/ios/start?authuser=0)

### SIWA
Singing in with Apple requires you to add the capabilites either in xcode or directly in the apple developer portal. 
Another thing to note in this project, the email extracted from apple credentials is valid only on the first login before it is registered in Firebase Authentication. Additional sign ins will cause the same credential ```(user.email)``` to acquire the second optional from the [Nil-Coalescing Operator](@note/Nil-CoalescingOperator.md) , which is a blank string.

#### Limiting Segues
If we register a user, we only want the button that prompts us to the next screen to be active only if all of the criteria is met and the register process is successful. Here we give the storyboard segue an identifier:
 ![Image](@attachment/Screen Shot 2021-09-28 at 10.01.03 AM.png)

 You must then create the segue from view controller to view controller, like so: 
 ![Image](@attachment/Screen Shot 2021-09-28 at 11.02.11 AM.png)

The following allows you perform the segue:
```swift
self.performSegue(withIdentifier: "RegisterToProfile", sender: self)
```

#### Reference
Apple Documentation:
[Apple's Sign In Documentation](https://developer.apple.com/documentation/authenticationservices/implementing_user_authentication_with_sign_in_with_apple)

Setup w/ Firebase:
[Blog #1](https://swiftsenpai.com/development/sign-in-with-apple-firebase-auth/)
[Blog #2 (Referenced in the first blog)](https://fluffy.es/sign-in-with-apple-tutorial-ios/)


***
## [<mark>Storing Profile Data</mark>](https://firebase.google.com/docs/firestore/manage-data/add-data?authuser=0#swift_10)
This section will entail how the data is stored into Firebase via setting the data and updating existing data. This section will also include methods for adding/removing to a nested array in the dictionary. 

Here I initialize the data collection. Here, I set the instantiation of the database in a global class to use it anywhere.
```swift
  let docData: [String: Any] = [
                            
      "email": email,
      "firstName" : self.firstNameField.text!,
      "lastName" : self.lastNameField.text!,
      "phoneNumber" : self.phoneNumberField.text!,
      "dateCreated" : self.myDate()

  ]

  Global.db.collection("userData").document(Global.userID!).setData(docData){ err in
      if let err = err {
          print("Error writing document: \(err)")
      } else {
          print("Document successfully written!")
      }
  }
```

This next snippet will show updates to the same collection. Using the above method would get rid of the previous collection and reinforce the last .setData that is called. 

```swift
    let docData: [String : Any] = [
        "city" : cityField.text!,
        "state" : stateField.text!
    ]
    
    Global.db.collection("userData").document(Global.userID!).updateData(docData){ err in
        if let err = err {
            print("Error writing document: \(err)")
        } else {
            print("Document successfully written!")
        }
    }
```

#### How to Add/Remove items from an array
In this section, there's a button array that I traverse throough, where if the button was selected, it would be stored in the array. If it was deselected, then it would be removed from the array. The FieldValue object is from `import Firebase` that allows the dev to access the connected Firebase project.

```swift
  Global.db.collection("userData").document(Global.userID!).updateData([

    "career" : careerTextField.text!,
    "categories" : FieldValue.arrayUnion([button.currentTitle!])
    
    ]){ err in
    if let err = err {
        print("Error updating document: \(err)")
    } else {
        print("Document successfully updated")
    }
}
```

The code below denotes the button as being deselcted. The first line checks to see if the button is already in the array. If so, then we would remove it. **NOTE:** `reg.profile.categories` is where I stored the categories to for this check.

```swift
  if reg.profile.categories.contains(button.currentTitle!){
        if let index = reg.profile.categories.firstIndex(of: button.currentTitle!){
            reg.profile.categories.remove(at: index)
        }
        Global.db.collection("userData").document(Global.userID!).updateData([
            "categories" : FieldValue.arrayRemove([button.currentTitle!])
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    } else{
        continue
    }
}
```
***
## [<mark>Storage</mark>](https://firebase.google.com/docs/storage/ios/start)
This is the [<mark>upload</mark>](https://firebase.google.com/docs/storage/ios/upload-files) portion of profile pictures to the database. In-message photos not included. Here, I grab the imageData and reference it to the storage, push the image data and metaData, and sets the storage URL to the Firestore base to later retrieve the link in the Homepage View.
```swift
  let storageBucket : String = "gs://mentorapp-9a6b5.appspot.com/"
  let storage = Storage.storage()
  let metadata = StorageMetadata()

  guard let imageSelected = self.image else{
      print("Profile is nil")
      return
  }

  guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else { return}

  let storagePath = "\(storageBucket)"
  let storageRef = storage.reference(forURL: storagePath)

  let imageRef = storageRef.child("images").child(Global.userID!)


  metadata.contentType = "image/jpeg"

  imageRef.putData(imageData, metadata: metadata) { storageMetaData, error in
      if error != nil{
          print(error?.localizedDescription ?? "Yo")
          return
      }
      
      imageRef.downloadURL(completion: { (url, error) in
          if let metaImageUrl = url?.absoluteString{
              print(metaImageUrl)
              Global.db.collection("userData").document(Global.userID!).updateData([
                  "profile-image" : metaImageUrl
              ]) { err in
                  if let err = err {
                      print("Error writing document: \(err)")
                  } else {
                      print("Document successfully written!")
                  }
                  
              }
          }
      })
```

***
## [<mark>Queries</mark>](https://firebase.google.com/docs/firestore/query-data/queries)

In this code snippet that I used in the mentorApp's HomepageView, I access the docData that we added to database from the registration portal. The closure gets the documents based on the query parameters that is initialized above. Here we set the dictionary value of the corresponding key (string). `data` allows us to do so by providing the dictonary. sd_setImage is function that is imported from `FirebaseStorageUI`. This is not included with Firebase so added FirebaseStorageUI in the Pods file will do the trick. 

```swift
let typeRef = Global.db.collection("userData")
let query = typeRef.whereField("type", isEqualTo: "Mentor")

query.getDocuments { querySnapshot, err in

  if let document = querySnapshot?.documents[self.docArrayStart]{
    let data = document.data()

    if let firstN = data["firstName"] as? String,
        let lastN = data["lastName"] as? String,
        let categories = data["categories"] as? [String],
        let career = data["career"] as? String,
        let pic = data["profile-image"] as? String
    {
        let storageRef = Storage.storage().reference(forURL: pic)
        self.profilePicture.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "\(Global.userID!).png"))
        self.firstNameLabel.text = "\(firstN) \(lastN)"
        self.careerLabel.text = career
        
        for category in categories {
            self.listOfCategories.text! += "\(category)\n"
        }
      }
   }
}

```



