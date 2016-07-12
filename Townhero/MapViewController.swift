//
//  ViewController.swift
//  TownHero
//
//  Created by Mohamed on 6/30/16.
//  Copyright © 2016 Mohamed. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBookUI
import MapKit
import FirebaseStorage
import FirebaseAuth
import Firebase
import SideMenu


class MapViewController: UIViewController, MKMapViewDelegate, mapDelegate{
    
    var lat = 0.0
    var long = 0.0
    
    
    let rootRef = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var addresslabel: UILabel!
    
    
    
    
    var buttoPressedName: String?
    
    
    var get = 0
    
    var natures = [Nature]()
    var parkings = [Parking]()
    var safetys = [Safety]()
    var services = [Service]()
    
    
    var zipCode: String?
    
    
    var didCall = 0
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.get = 1
        
        locationManager.requestWhenInUseAuthorization()
        //        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotationFromGes(_:)))
        uilgr.minimumPressDuration = 0.3
        
        self.mapView.addGestureRecognizer(uilgr)
        
        self.mapView.delegate = self
        
        //Zoom
        
        
        
        
        
        
        
    }
    
    //Hide Status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        if self.get == 1 {
            self.mapView.setRegion(MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(0.005, 0.005)), animated: true)}
        
        let geoCoder = CLGeocoder()
        
        
        let location = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            
            if self.get == 1 {
                self.get = self.get + 1
                if let city = placeMark.addressDictionary!["City"] as? NSString {
                    if let Zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                        self.addresslabel.text = (city as String) + ", " + (placeMark.addressDictionary!["ZIP"] as? String)!
                        self.zipCode = Zip as String
                        self.didCall = self.didCall + 1
                        if self.didCall == 1 {
                            self.retrievePosts()}
                    }
                }
            }
            
        })
        
    }
    
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            let colorPointAnnotation = annotation as! ColorPointAnnotation
            pinView?.pinTintColor = colorPointAnnotation.pinColor
            pinView!.rightCalloutAccessoryView = UIButton(type: .InfoDark)
            
            pinView?.canShowCallout = true
            
            
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    //
    //
    //        pin.canShowCallout = true
    //        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
    //        pin.pinTintColor = UIColor.yellowColor()
    //        return pin
    //
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        //change this to Coordinates for better search
        
        
        for item in natures{
            
            if item.des == (view.annotation?.subtitle)! && item.title == (view.annotation?.title)!
            {
                let storyboard = UIStoryboard(name: "InfoPin", bundle: nil)
                let pvc = storyboard.instantiateViewControllerWithIdentifier("InfoPin") as! InfoPin
                pvc.nature = item
                pvc.kind = "nature"
                self.presentViewController(pvc, animated: true, completion: nil)
                
            }
            
        }
        
        
        for item in parkings{
            
            if item.des == (view.annotation?.subtitle)! && item.title == (view.annotation?.title)!
            {
                let storyboard = UIStoryboard(name: "InfoPin", bundle: nil)
                let pvc = storyboard.instantiateViewControllerWithIdentifier("InfoPin") as! InfoPin
                pvc.parking = item
                pvc.kind = "parking"
                self.presentViewController(pvc, animated: true, completion: nil)
                
            }
            
        }
        
        for item in safetys{
            
            if item.des == (view.annotation?.subtitle)! && item.title == (view.annotation?.title)!
            {
                let storyboard = UIStoryboard(name: "InfoPin", bundle: nil)
                let pvc = storyboard.instantiateViewControllerWithIdentifier("InfoPin") as! InfoPin
                pvc.safety = item
                pvc.kind = "safety"
                self.presentViewController(pvc, animated: true, completion: nil)
                
            }
            
        }
        
        for item in services{
            
            if item.des == (view.annotation?.subtitle)! && item.title == (view.annotation?.title)!
            {
                let storyboard = UIStoryboard(name: "InfoPin", bundle: nil)
                let pvc = storyboard.instantiateViewControllerWithIdentifier("InfoPin") as! InfoPin
                pvc.services = item
                pvc.kind = "service"
                self.presentViewController(pvc, animated: true, completion: nil)
                
            }
            
        }
        
        
    }
    
    func addMapNotation1(tempParking: Parking) -> Void{
        
        let myOutput1: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("parkingSwitch")
        
        let point = ColorPointAnnotation(pinColor: UIColor.blueColor())
        
        
        point.coordinate.latitude = Double(tempParking.lat!)!
        point.coordinate.longitude = Double(tempParking.long!)!
        
        
        point.title = tempParking.title
        point.subtitle = tempParking.des
        
        
        
        if let myOutput10 = myOutput1 {
            
            if myOutput10 as! String == "1"{
                
            }else{
                
                
                
                self.mapView.addAnnotation(point)
                self.mapView.reloadInputViews()
                
            }
            
        }
        
    }//End of addMapNotation func
    
    func addMapNotation2(tempParking: Nature) -> Void{
        let myOutput1: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("envirementSwitch")
        
        
        let point = ColorPointAnnotation(pinColor: UIColor.greenColor())
        
        point.coordinate.latitude = Double(tempParking.lat!)!
        point.coordinate.longitude = Double(tempParking.long!)!
        
        point.title = tempParking.title
        point.subtitle = tempParking.des
        
        if let myOutput10 = myOutput1 {
            
            if myOutput10 as! String == "1"{
                
            }else{
                
                
                
                self.mapView.addAnnotation(point)
                self.mapView.reloadInputViews()
                
            }
            
        }
    }//End of addMapNotation func
    
    func addMapNotation3(tempParking: Safety) -> Void{
        let myOutput1: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("safetySwitch")
        
        let point = ColorPointAnnotation(pinColor: UIColor.redColor())
        point.coordinate.latitude = Double(tempParking.lat!)!
        point.coordinate.longitude = Double(tempParking.long!)!
        
        point.title = tempParking.title
        point.subtitle = tempParking.des
        
        
        if let myOutput10 = myOutput1 {
            
            if myOutput10 as! String == "1"{
                
            }else{
                
                
                
                self.mapView.addAnnotation(point)
                self.mapView.reloadInputViews()
                
            }
            
        }
        
    }//End of addMapNotation func
    
    
    func addMapNotation4(tempParking: Service) -> Void{
        let myOutput1: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("serviceSwitch")
        
        let point = ColorPointAnnotation(pinColor: UIColor.yellowColor())
        point.coordinate.latitude = Double(tempParking.lat!)!
        point.coordinate.longitude = Double(tempParking.long!)!
        
        point.title = tempParking.title
        point.subtitle = tempParking.des
        
        if let myOutput10 = myOutput1 {
            
            if myOutput10 as! String == "1"{
                
            }else{
                
                
                
                self.mapView.addAnnotation(point)
                self.mapView.reloadInputViews()
                
            }
            
        }
        
    }//End of addMapNotation func
    
    
    
    
    //Load Posts
    func retrievePosts() -> Void {
        
        let condition1 = rootRef.child("Post").child(self.zipCode!).child("UIDeviceRGBColorSpace 0 0 1 1")
        condition1.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            let tempDic: [String: [String]] = snapshot.value as! Dictionary
            
            
            
            
            var tempArray = tempDic["cordinates"]
            
            
            
            var tempString = tempDic["title"]
            var tempDes = tempDic["description"]
            var tempCor = tempDic["cordinates"]
            var tempPhoto = tempDic["photoURL"]
            
            var tempParking = Parking(tempTitle: tempString![0], tempDes: tempDes![0] , tempLat: tempCor![0] , tempLong: tempCor![1], tempPhoto: tempPhoto![0])
            
            
            self.parkings.append(tempParking)
            
            
            self.addMapNotation1(tempParking)
        })
        
        
        let condition2 = rootRef.child("Post").child(self.zipCode!).child("UIDeviceRGBColorSpace 0 1 0 1")
        condition2.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            let tempDic: [String: [String]] = snapshot.value as! Dictionary
            
            
            
            
            var tempArray = tempDic["cordinates"]
            
            var tempString = tempDic["title"]
            var tempDes = tempDic["description"]
            var tempCor = tempDic["cordinates"]
            var tempPhoto = tempDic["photoURL"]
            
            
            var tempParking = Nature(tempTitle: tempString![0], tempDes: tempDes![0] , tempLat: tempCor![0] , tempLong: tempCor![1], tempPhoto: tempPhoto![0])
            
            
            
            self.natures.append(tempParking)
            
            
            self.addMapNotation2(tempParking)
        })
        
        let condition3 = rootRef.child("Post").child(self.zipCode!).child("UIDeviceRGBColorSpace 1 0 0 1")
        condition3.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            let tempDic: [String: [String]] = snapshot.value as! Dictionary
            
            
            
            
            var tempArray = tempDic["cordinates"]
            
            var tempString = tempDic["title"]
            var tempDes = tempDic["description"]
            var tempCor = tempDic["cordinates"]
            var tempPhoto = tempDic["photoURL"]
            
            
            var tempParking = Safety(tempTitle: tempString![0], tempDes: tempDes![0] , tempLat: tempCor![0] , tempLong: tempCor![1], tempPhoto: tempPhoto![0])
            
            
            
            self.safetys.append(tempParking)
            
            
            self.addMapNotation3(tempParking)
        })
        
        
        
        let condition4 = rootRef.child("Post").child(self.zipCode!).child("UIDeviceRGBColorSpace 1 1 0 1")
        condition4.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            let tempDic: [String: [String]] = snapshot.value as! Dictionary
            
            
            var tempArray = tempDic["cordinates"]
            var tempString = tempDic["title"]
            var tempDes = tempDic["description"]
            var tempCor = tempDic["cordinates"]
            var tempPhoto = tempDic["photoURL"]
            
            let tempParking = Service(tempTitle: tempString![0], tempDes: tempDes![0] , tempLat: tempCor![0] , tempLong: tempCor![1], tempPhoto: tempPhoto![0])
            
            
            
            self.services.append(tempParking)
            
            
            self.addMapNotation4(tempParking)
        })
        
    }//End of the retrievePosts func
    
    
    
    func addAnnotationFromGes(gestureRecognizer:UIGestureRecognizer){
        
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(self.mapView)
            let newCoordinates = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            //
            
            self.lat = newCoordinates.latitude
            self.long = newCoordinates.longitude
            //            tempPoint?.coordinate.latitude = newCoordinates.latitude
            //            tempPoint?.coordinate.longitude = newCoordinates.longitude
            //
            
            
            //  dvc.point?.coordinate = newCoordinates
            
            performSegueWithIdentifier("showView", sender: nil)
            
            
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showView"{
            let dvc = segue.destinationViewController as! PinDetailViewController
            
            //Sometimes there is a dely when getting lat and Long so if self.lat is nil or lon is nil call get the info again
            dvc.lat = self.lat
            dvc.long = self.long
        }
        
        
        if segue.identifier == "sideBarSegue" {
            
            let ptr = segue.destinationViewController as! UISideMenuNavigationController
            
            print(ptr.childViewControllers)
            let tabBarChildren = ptr.childViewControllers.first?.childViewControllers
            for child in tabBarChildren! {
                if let profile = child as? ProfileTVC {
                    profile.mapdelegate = self
                }
            }
            
        }
        
    }
    
    
    
    
    
    
    func safetySwitch(){
        let myOutput1: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("safetySwitch")
        
        if let myOutput10 = myOutput1 {
            
            if myOutput10 as! String == "0"{
                print("I am presseD  0")
                
                for item in safetys{
                    
                    let point = ColorPointAnnotation(pinColor: UIColor.redColor())
                    
                    
                    point.coordinate.latitude = Double(item.lat!)!
                    point.coordinate.longitude = Double(item.long!)!
                    
                    
                    point.title = item.title
                    point.subtitle = item.des
                    self.mapView.addAnnotation(point)
                    self.mapView.reloadInputViews()
                    
                }
            }else{
                let points = self.mapView.annotations
                for item in safetys{
                    for tempPoint in points{
                        if tempPoint.coordinate.latitude == Double(item.lat!)! && tempPoint.coordinate.longitude == Double(item.long!)! {
                                self.mapView.removeAnnotation(tempPoint)
                                self.mapView.reloadInputViews()
                            }//End  of if statement
                    }//End of the loop
                }//End of the parent loop
            }//End of the else statement
        }
        
        
    }
    
    func parkingSwitch(){
        let myOutput1: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("parkingSwitch")
        
        if let myOutput10 = myOutput1 {
            
            if myOutput10 as! String == "0"{
                print("I am presseD  0")
                
                for item in parkings{
                    
                    let point = ColorPointAnnotation(pinColor: UIColor.blueColor())
                    
                    
                    point.coordinate.latitude = Double(item.lat!)!
                    point.coordinate.longitude = Double(item.long!)!
                    
                    
                    point.title = item.title
                    point.subtitle = item.des
                    self.mapView.addAnnotation(point)
                    self.mapView.reloadInputViews()
                    
                }
            }else{
                let points = self.mapView.annotations
                for item in parkings{
                    for tempPoint in points{
                        if tempPoint.coordinate.latitude == Double(item.lat!)! && tempPoint.coordinate.longitude == Double(item.long!)! {
                            self.mapView.removeAnnotation(tempPoint)
                            self.mapView.reloadInputViews()
                        }//End  of if statement
                    }//End of the loop
                }//End of the parent loop
            }//End of the else statement
        }
        
        
    }
    
    func envirementSwitch(){
        let myOutput1: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("envirementSwitch")
        
        if let myOutput10 = myOutput1 {
            
            if myOutput10 as! String == "0"{
                print("I am presseD  0")
                
                for item in natures{
                    
                    let point = ColorPointAnnotation(pinColor: UIColor.greenColor())
                    
                    
                    point.coordinate.latitude = Double(item.lat!)!
                    point.coordinate.longitude = Double(item.long!)!
                    
                    
                    point.title = item.title
                    point.subtitle = item.des
                    self.mapView.addAnnotation(point)
                    self.mapView.reloadInputViews()
                    
                }
            }else{
                let points = self.mapView.annotations
                for item in natures{
                    for tempPoint in points{
                        if tempPoint.coordinate.latitude == Double(item.lat!)! && tempPoint.coordinate.longitude == Double(item.long!)! {
                            self.mapView.removeAnnotation(tempPoint)
                            self.mapView.reloadInputViews()
                        }//End  of if statement
                    }//End of the loop
                }//End of the parent loop
            }//End of the else statement
        }
        
        
    }
    
    func serviceSwitch(){
        let myOutput1: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("serviceSwitch")
        
        if let myOutput10 = myOutput1 {
            
            if myOutput10 as! String == "0"{
                print("I am presseD  0")
                
                for item in services{
                    
                    let point = ColorPointAnnotation(pinColor: UIColor.yellowColor())
                    
                    
                    point.coordinate.latitude = Double(item.lat!)!
                    point.coordinate.longitude = Double(item.long!)!
                    
                    
                    point.title = item.title
                    point.subtitle = item.des
                    self.mapView.addAnnotation(point)
                    self.mapView.reloadInputViews()
                    
                }
            }else{
                let points = self.mapView.annotations
                for item in services{
                    for tempPoint in points{
                        if tempPoint.coordinate.latitude == Double(item.lat!)! && tempPoint.coordinate.longitude == Double(item.long!)! {
                            self.mapView.removeAnnotation(tempPoint)
                            self.mapView.reloadInputViews()
                        }//End  of if statement
                    }//End of the loop
                }//End of the parent loop
            }//End of the else statement
        }
        
        
    }
    


  


    
    
}//End of the VC Class


