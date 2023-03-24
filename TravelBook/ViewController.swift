//
//  ViewController.swift
//  TravelBook
//
//  Created by Mehmet Sukru Kavak on 14.03.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    var locationManager = CLLocationManager()
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    @IBOutlet weak var saveButton: UIButton!
    var chosenPlaceTitle : String = ""
    var chosenPlaceId : UUID?
    
    var annotationTitle = ""
    var annotationComment = ""
    var annotationLongitude = Double()
    var annotationLatitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if chosenPlaceTitle != "" {
            //CoreData
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = chosenPlaceId!.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                
                let results = try context.fetch(fetchRequest)
                
                if  results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String{
                            if let comment = result.value(forKey: "comment") as? String{
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    if let longitude = result.value(forKey: "longitude") as? Double{
                                       annotationTitle = title
                                       annotationComment = comment
                                        annotationLongitude = longitude
                                        annotationLatitude = latitude
                                        
                                        nameText.isEnabled = false
                                        commentText.isEnabled = false
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationComment
                                        
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                                
                                
                            }
                            
                           
                        }
                        
                       
                        
                       
                    }
                }
                        
                
                
            } catch {
                print("error")
            }
            
        } else {
            saveButton.isHidden = false
            nameText.isEnabled = true
            commentText.isEnabled = true
        }
        
        
    }
    
    @objc func pinLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation ()
            annotation.coordinate = touchedCoordinates
            if let name = nameText.text {
                if let comment = commentText.text {
                    annotation.title = name
                    annotation.subtitle = comment
                }
               
            }
           
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if chosenPlaceTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
        }
        
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
       
            let button = UIButton (type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        
        } else {
            
            pinView?.annotation = annotation
        }
        return pinView
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "comment")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(UUID(), forKey: "id")
       
        do {
            try context.save ()
                print ("success")
        } catch {
            print ("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
}

