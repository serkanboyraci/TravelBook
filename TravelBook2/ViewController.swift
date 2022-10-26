
//
//  ViewController.swift
//  TravelBook2
//
//  Created by Ali serkan Boyracı  on 27.09.2022.
//

import UIKit
import MapKit // to add Map function
import CoreLocation // to add user location
import CoreData // to use phone data

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var nameText: UITextField!
    
    @IBOutlet var commentText: UITextField!
    
    

    @IBOutlet var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var chosenLatitude = Double() //to use coordinates in save button func.
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedID : UUID?
    
    // define annotitation variables
    var annotationtitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // to show your location accuracy
        locationManager.requestWhenInUseAuthorization() // to take authorization using app
        locationManager.startUpdatingLocation() // to upadte location
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        
        
        
        gestureRecognizer.minimumPressDuration = 3 // tap how many seconds to add pin, optimum time is 3.
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //to take data from Core Data
        if selectedTitle != "" {
            
            saveButton.isHidden = true // you must define saveButton in storyboard as outlet
            
            //to take Data -to hide svae button
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            
            let idString = selectedID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString) //to take only this id number
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        //
                        if let title = result.value(forKey: "title") as? String {
                            annotationtitle = title
                            // this way, if one of them cant take data, it wont show any of them
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationtitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationtitle
                                        commentText.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation() // yto show annotation coordinate
                                        // to zoom and show the area
                                        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                        
                                    }
                                }
                            }
                        }
                        /* this way, if one of them cant take data, it wont show only that one.
                        if let title = result.value(forKey: "title") as? String {
                            annotationtitle = title
                        }
                        if let subtitle = result.value(forKey: "subtitle") as? String {
                            annotationSubtitle = subtitle
                        }
                        if let latitude = result.value(forKey: "latitude") as? Double {
                            annotationLatitude = latitude
                        }
                        if let longitude = result.value(forKey: "longitude") as? Double {
                            annptationLongitude = longitude
                        }
                        */
                    
                        //after taking data from DataCore, we must define  annotation variables
                    }
                }
            } catch {
                print("error")
            }
            
            
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            // add new Data
        }
        
        
        
        
    }
                                                             

    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) { //adding gestureRecognizer in paranthesis, we can reach its attributes.
        
        if gestureRecognizer.state == .began { //if somebody touch screen lonnnggggg
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView) // to learn exact location
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView) // we must changed coordinate system.
            
            chosenLatitude = touchedCoordinates.latitude //to use coordinates in save button func.
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation() // to add pin
            annotation.coordinate = touchedCoordinates // pins coordinates
            annotation.title = nameText.text //to give name to pin
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
            
            saveButton.isEnabled = true // after touching long press and adding pin save button activated.
            
        }
        
            
            
            
            
        }
                                       

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { // after learning user location, to use it
        // it gives us locations in [Array]
        // use this func only
        if selectedTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            // to give zoom level
            let span = MKCoordinateSpan(latitudeDelta: 0.060, longitudeDelta: 0.060) // to more exact, it must be lowest number.
            
            // to gives exact region, area
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            // it will do code number 57.
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { // to custom annotation,
        // in short, we make an annotation btw we return it.
        if annotation is MKUserLocation { //we dont want user locatiın as annotation
            return nil
        }
        
        let reuseID = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView // after IOS16 MarkerAnnotationView
        
        if pinView == nil { //means pinview is not exist.
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            
            // starting customizing annotation
            pinView?.canShowCallout = true // to give permit extra info
            pinView?.tintColor = UIColor.black // to change its color.
            
            // we define pin button.
            let button = UIButton(type : UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button // to put its right side
        }
        else {
            pinView?.annotation  = annotation //means already we have pin
        }
        return pinView
    }
    
    // annotation extra info button tapped function
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // means we have one point.
        if selectedTitle != "" {
            
            // to add requestLocation to do navigate also we nned exact location for CLGeocoder func.
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in //closure- it gives us placemark array or error
                
                // we need placemark array to start navigation
                if let placemark = placemarks {
                
                    if placemark.count > 0 { // we have to use if let structure.
                    
                        let newPlacemark = MKPlacemark(placemark: placemark[0]) // to open mapitem we must define placemark
                        let item = MKMapItem(placemark: newPlacemark) // to open  navi, we must define mapitem
                        item.name = self.annotationtitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions) // to use openInMaps, we must define launchoptions.
                        
                    }
                }
             
                
            }
            
            
            
        }
    }
    
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        // when using core data, everytime you must use appDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // to save core data
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        
        do {
            try context.save()
            print("success")
        } catch {
            print("ERROR")
        }
        // to message(newPlace) to app to do sth.
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true) // to go back VC
        
        
        
        
        
        
        
        
        
        
    }
    
    
    

}

