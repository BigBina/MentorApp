---
attachments: [Screen Shot 2021-09-28 at 10.01.03 AM.png, Screen Shot 2021-09-28 at 11.02.11 AM.png]
title: Firebase
created: '2021-09-27T18:08:53.291Z'
modified: '2021-10-12T19:05:08.280Z'
---

# Firebase
### [Authentication](https://firebase.google.com/docs/auth/ios/start?authuser=0)

#### SIWA
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


## 
### Storing Profile Data



