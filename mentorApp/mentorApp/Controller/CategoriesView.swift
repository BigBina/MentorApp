//
//  CategoriesView.swift
//  mentorApp
//
//  Created by Brandon Brown on 10/4/21.
//

import UIKit

class CategoriesView: UIViewController {
    
    

    @IBOutlet weak var careerTextField: UITextField!
    @IBOutlet weak var fitnessButton: UIButton!
    @IBOutlet weak var financialButton: UIButton!
    @IBOutlet weak var jobButton: UIButton!
    @IBOutlet weak var associatesButton: UIButton!
    @IBOutlet weak var cultureButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    //Career Categories
    var careerCategories : [String] = ["Engineering/Tech", "Medical Field", "Sports/Sports Management", "Political Science","Philosophy", "Entrepreneurship", "Arts", "Business", "Entertainment", "Management", "Social Services"]
    
    //Created a button array to check the attributes of each button
    var buttonArray : [UIButton] = [UIButton]()
    
    //PickerView Instantiation
    var pickerView = UIPickerView()
    
    var profile: Profile = Profile(firstName: "", lastName: "", phoneNumber: "", city: "", state: "", bio: "", type: "", categories: [], career: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keyboard Method
        hideKeyboardWhenTappedAround()

        //Button Attributes
        buttonAttributes()
        
        //PickerView Attributes
        pickerViewAttributes()
        //Initializing the buttonArray
        self.buttonArray = [self.fitnessButton, self.financialButton, self.jobButton, self.associatesButton, self.cultureButton]
    }
    
    func pickerViewAttributes(){
        
        //Setup for pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
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
    }
    //#selector has to refer to an objc function
    @objc func closePickerView(){
        view.endEditing(true)
    }
    
    func buttonAttributes() {
        fitnessButton.layer.cornerRadius = 20
        financialButton.layer.cornerRadius = 20
        jobButton.layer.cornerRadius = 20
        associatesButton.layer.cornerRadius = 20
        cultureButton.layer.cornerRadius = 20
        nextButton.layer.cornerRadius = 20
    }
    
    
    
//MARK: - Button Selectors
    @IBAction func fitnessButton(_ sender: UIButton) {
        
        if fitnessButton.isSelected == false{
            fitnessButton.isSelected = true
            fitnessButton.isHighlighted = true
            fitnessButton.backgroundColor = .link
            //then we append this to the profile struct
            print("Highlighted")
        } else {
            fitnessButton.isSelected = false
            fitnessButton.isHighlighted = false
            fitnessButton.backgroundColor = .systemBackground
            //remove it from the profile struct
            print("Not highlighted")
        }
    }
    
    @IBAction func financialButton(_ sender: UIButton) {
        if financialButton.isSelected == false{
            financialButton.isSelected = true
            financialButton.isHighlighted = true
            financialButton.backgroundColor = .link
            //then we append this to the profile struct
            print("Highlighted")
        } else {
            financialButton.isSelected = false
            financialButton.isHighlighted = false
            financialButton.backgroundColor = .systemBackground
            //remove it from the profile struct
            print("Not highlighted")
        }
    }
    
    @IBAction func jobButton(_ sender: UIButton) {
        if jobButton.isSelected == false{
            jobButton.isSelected = true
            jobButton.isHighlighted = true
            jobButton.backgroundColor = .link
            //then we append this to the profile struct
            print("Highlighted")
        } else {
            jobButton.isSelected = false
            jobButton.isHighlighted = false
            jobButton.backgroundColor = .systemBackground
            //remove it from the profile struct
            print("Not highlighted")
        }
    }
    
    @IBAction func associatesButton(_ sender: UIButton) {
        if  associatesButton.isSelected == false{
            associatesButton.isSelected = true
            associatesButton.isHighlighted = true
            associatesButton.backgroundColor = .link
            //then we append this to the profile struct
            print("Highlighted")
        } else {
            associatesButton.isSelected = false
            associatesButton.isHighlighted = false
            associatesButton.backgroundColor = .systemBackground
            //remove it from the profile struct
            print("Not highlighted")
        }
    }
    
    @IBAction func cultureButton(_ sender: UIButton) {
        if  cultureButton.isSelected == false{
            cultureButton.isSelected = true
            cultureButton.isHighlighted = true
            cultureButton.backgroundColor = .link
            //then we append this to the profile struct
            print("Highlighted")
        } else {
            cultureButton.isSelected = false
            cultureButton.isHighlighted = false
            cultureButton.backgroundColor = .systemBackground
            //remove it from the profile struct
            print("Not highlighted")
        }
    }
    
    //MARK: - Next Segue Check
    @IBAction func nextButton(_ sender: Any) {
        for button in buttonArray{
            if button.isSelected == true{
                //store it and next segue
                if profile.categories.contains(button.currentTitle!){
                    continue
                } else {
                    profile.categories.append(button.currentTitle!)
                    print(profile.categories)
                }
            } else{
                continue
            }
        }
//        performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
    }
    
    
    
}
// once im in the next button, loop through the button array and check if the selected is true. If true set it to the categories array
//MARK: - Picker View for the Career Field
extension CategoriesView: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return careerCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return careerCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        careerTextField.text = careerCategories[row]
//        careerTextField.resignFirstResponder()
    }
    
    


}


