---
attachments: [Screen Shot 2021-10-05 at 11.12.46 PM.png]
title: CLLocationManger
created: '2021-10-06T04:04:36.578Z'
modified: '2021-10-14T07:16:42.965Z'
---

# CLLocationManger

```swift
import CoreLocation
```
[Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager)
This class allows you to add location-related events to an app.
You use instances of this class to configure, start, and stop the Core Location services. A location manager object supports the following location-related activities:
- Tracking large or small changes in the user’s current location with a configurable degree of accuracy.
- Reporting heading changes from the onboard compass.
- Monitoring distinct regions of interest and generating location events when the user enters or leaves those regions.
- Reporting the range to nearby beacons.
### Privacy
![nf](@attachment/Screen Shot 2021-10-05 at 11.12.46 PM.png)

***
## CLPlacemark 
The CLPlacemark is an object that stores placemark data for a given lat and lon. Placemark data includes information such as the country or region, state, city, and street address associated with the specified coordinate. It can also include points of interest and geographically related data.

When you reverse geocode a latitude and longitude coordinate using a **CLGeocoder**, you receive a **CLPlacemark** object. The code directly below shows the methods of CLLocationManagerDelegate. In the IBAction for the button, once the button is pressed, then we request for authorization from the users privacy settings(set in the info.plist). There are 2 methods that are required when using this delegate. The first method is didUpdateLocations and the brain behind it, is that it checks to see if the locations have updated, by locations being stored in the array ``[CLLocation]``. Here we set the location as the most recent of locations accquire from requesting above. Then, I instantiate the geocoder class to convert the coordinate to the user-friendly representation of that coordinate. ``Reverse-geocoding requests takes a latitude and longitude value and find a user-readable address.``
```swift 
geocoder.reverseGeocodeLocation(locationB) 
```


```swift
extension LocationView: CLLocationManagerDelegate, UITextFieldDelegate{
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
```
This processRespone function is where you specify which Placemark attributes you would like to access from the CLLocation. Reference to all the possible attributes: [<mark>**CLPlacemark**</mark>](https://developer.apple.com/documentation/corelocation/clplacemark)
In this function, I only requested the State and City of my current location. I also added a conditional if the fields are not filled out, then we prompt an error alert.

```swift
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
    @IBAction func nextButton(_ sender: Any) {
        if cityField.text != "" && stateField.text != ""{
            performSegue(withIdentifier: "LocationToCategories", sender: self)
        } else{
            errorLabel.text = "Please fill out required fields: City and State"
        }
    }
```

