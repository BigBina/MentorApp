//
//  LocationView.swift
//  mentorApp
//
//  Created by Brandon Brown on 10/4/21.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseStorage

class LocationView: UIViewController {
    
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bioField: UITextField!
    
    var pickerView = UIPickerView()
    let locationManager = CLLocationManager()
    
    var image: UIImage? = nil
    
    let storageBucket : String = "gs://mentorapp-9a6b5.appspot.com/"
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Keyboard Method
        hideKeyboardWhenTappedAround()
        
        //Picker View Initializers
        pickerView.delegate = self
        pickerView.dataSource = self
        stateField.inputView = pickerView
        stateField.textAlignment = .center
        
        //Location Initializers
        locationManager.delegate = self
        
        //Button Attributes
        nextButton.layer.cornerRadius = 20
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageView.addGestureRecognizer(gesture)
    }
    
    
    @objc private func didTap(){
        presentPhotoActionSheet()
    }

    ///Location function to convert geolaction to user friendly names such as City and State.
    public func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View

        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")

        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                cityField.text = placemark.locality
                stateField.text = placemark.administrativeArea
            } else {
                cityField.text = "No Matching Addresses Found"
            }
        }
    }
  
    fileprivate func errorFunc(_ err: Error?) {
        if let err = err {
            print("Error writing document: \(err)")
        } else {
            print("Document successfully written!")
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        //MARK: - Image Upload to FB Storage & Link Reference to Firestore
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
                    Global.db.collection(Constants.FB.userData).document(Global.userID!).updateData([
                        Constants.QueryKey.Picture : metaImageUrl
                    ]) { err in
                        self.errorFunc(err)
                    }
                    Global.profile.picture = metaImageUrl
                }
            })
        }
        
        //MARK: - City and State Update to Firestore
        if cityField.text != "" && stateField.text != "" {
      
            let docData: [String : Any] = [
                Constants.QueryKey.City : cityField.text!,
                Constants.QueryKey.State : stateField.text!,
                Constants.QueryKey.Bio : bioField.text!
            ]
            
            Global.db.collection(Constants.FB.userData).document(Global.userID!).updateData(docData){ err in
                self.errorFunc(err)
            }
            
            performSegue(withIdentifier: "LocationToCategories", sender: self)
            
        } else {
            errorLabel.text = "Please fill out required fields: City and State"
        }
    }
}

//MARK: - Picker View for the State Selection
extension LocationView: UIPickerViewDelegate, UIPickerViewDataSource {

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
//MARK: - Location Delegate with locationManager Methods
extension LocationView: CLLocationManagerDelegate {
    @IBAction func liveLocationButton(_ sender: Any) {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            self.locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            let locationB = CLLocation(latitude: lat, longitude: lon)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(locationB) { (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        print("Failed with Error")
    }
    
}
//MARK: - UI Image Delegates for Selecting & Editing Photos
extension LocationView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
