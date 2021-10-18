---
attachments: [Screen Shot 2021-10-14 at 1.31.25 AM.png]
title: PickerView
created: '2021-10-14T06:04:01.365Z'
modified: '2021-10-14T06:56:59.495Z'
---

# PickerView

The pickerView allows you to pick/select from any array of values. For example, in the states textField for the Location View Controller, once the user selects the field the user can choose from an accesible and scrollable view that displays all 50 states. 

Before we begin using the pickerView, we would have to instantiate the PickerView class and initiailize the delegate and dataSource to be able to have access to the customization of the pickerView:

```swift
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Picker View Initializers
        pickerView.delegate = self
        pickerView.dataSource = self

    }
```

Once that is established, we want to actually fill the pickerView with data and customize it to our liking. To be able to this, we have to add 2 Protocols to the class. I recommend adding an extension to the class for these protocols because it helps organize the code by removing the clutter and sectioning specific protocols that you can distinguish.

The 2 required protocol stubs are the `numberOfComponents` & `numberOfRowsInCompenent`. 

`titleForRow` & `didSelectRow` are the other 2 that are essential for building a picker view. So I believe these are required. For the states example, I created a dictionary that mapped the full name of a state with its abbreviation. The abbereviation value would go into the state text field once the corresponding key is selected.

`resignFirstResponder()` is function that resigns the pickerView once the pickerView's selector is set on a key.

```swift
extension LocationView: UIPickerViewDelegate, UIPickerViewDataSource{

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return States.stateTuple.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return States.stateTuple[row].full
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateField.text = States.stateTuple[row].abbr
        stateField.resignFirstResponder()
    }

}

```

<center>
  <markdown>
  #### Generic pickerView
  ![Image](@attachment/Screen Shot 2021-10-14 at 1.31.25 AM.png)
  </markdown>
</center>

I've done another pickerView where I instantiated the `UIToolbar` and customized it.

```swift

    //Toolbar Attributes
    let toolBar = UIToolbar()
    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.tintColor = UIColor(red: 66/255, green: 111/255, blue: 245/255, alpha: 1)
    toolBar.sizeToFit()

    let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.closePickerView))

    toolBar.setItems([doneButton], animated: false)
    toolBar.isUserInteractionEnabled = true

    careerTextField.inputView = pickerView
    careerTextField.inputAccessoryView = toolBar
    
```
