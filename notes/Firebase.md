---
attachments: [Screen Shot 2021-09-28 at 10.01.03 AM.png, Screen Shot 2021-09-28 at 11.02.11 AM.png]
title: Firebase
created: '2021-09-27T18:08:53.291Z'
modified: '2021-09-29T01:53:44.974Z'
---

# Firebase
### [Authentication](https://firebase.google.com/docs/auth/ios/start?authuser=0)

#### Limiting Segues
If we register a user, we only want the button that prompts us to the next screen to be active only if all of the criteria is met and the register process is successful. Here we give the storyboard segue an identifier:
 ![Image](@attachment/Screen Shot 2021-09-28 at 10.01.03 AM.png)

 You must then create the segue from view controller to view controller, like so: 
 ![Image](@attachment/Screen Shot 2021-09-28 at 11.02.11 AM.png)

The following allows you perform the segue:
```swift
self.performSegue(withIdentifier: "RegisterToProfile", sender: self)
```

####

