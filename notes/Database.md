---
title: Database
created: '2021-11-03T18:47:10.887Z'
modified: '2021-11-03T19:02:42.655Z'
---

# Database
### Collection: Message
- UserID
  - Conversations
    - messages with other USERID (name)
      - msg: message1
      - msg: message2
      - msg: message3
    - messages with other USERID (name)
      - message1
      - message2
      - message3


```swift
let messageRef = db.collection("Messages").collection(User.uid).collection("EmailofOtherUser_"\(type)).document("message")
```
