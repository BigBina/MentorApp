---
title: Nil-CoalescingOperator
created: '2021-09-27T19:23:00.962Z'
modified: '2021-09-28T19:12:46.755Z'
---

# Nil-CoalescingOperator
### ??
The nil-coalescing operator lets you specify an optional, and a default value
if anything to the left of the operator is nil, then we take the latter option, which is on the right of the **??** operator. That means it prioritizes from left to right. An [example](https://docs.swift.org/swift-book/LanguageGuide/BasicOperators.html) found on swift's documentation states:
```swift
var defaultColorName = "red"
var userDefinedColorName: String?   // defaults to nil

var colorNameToUse = userDefinedColorName ?? defaultColorName
// userDefinedColorName is nil, so colorNameToUse is set to the default of "red"
// ------------

userDefinedColorName = "green"
colorNameToUse = userDefinedColorName ?? defaultColorName
// userDefinedColorName isn't nil, so colorNameToUse is set to "green"

```






Here's a more clear example that is actually used and that is related to the Apple ID Credentials Structure,
```swift 
struct Apple{
    let user : String
    let firstName : String
    let lastName : String
    let email : String
    
    init(appleIDCredentials: ASAuthorizationAppleIDCredential){
        self.user = appleIDCredentials.user
        self.firstName = appleIDCredentials.fullName?.givenName ?? ""
        self.lastName = appleIDCredentials.fullName?.familyName ?? ""
        self.email = appleIDCredentials.email ?? ""
    }
}
```

