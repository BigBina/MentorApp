---
attachments: [Screen Shot 2021-09-28 at 10.01.03 AM.png]
title: Firebase
created: '2021-09-27T18:08:53.291Z'
modified: '2021-09-28T15:47:46.591Z'
---

# Firebase
### Authentication

#### Limiting Segues
If we register a user, we only want the button that prompts us to the next screen to be active only if all of the criteria is met and the register process is successful. Here we give the storyboard segue an identifier:
 ![Image](https://github.com/BigBina/MentorApp/tree/main/attachments/Screen Shot 2021-09-28 at 10.01.03 AM.png)

The following allows you perform the segue:
```swift
self.performSegue(withIdentifier: "RegisterToProfile", sender: self)
```


