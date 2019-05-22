//
//  MapViewController.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 21/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    enum DisplayMode: Int {
        case Bikes = 0
        case Slots = 1
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var stationArray: [Station] = []
    var selectedStation: Station!
    var displayMode: DisplayMode = DisplayMode.Bikes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchLocalStations()
        addAllMapAnnotations()
        
        let locationRadius = CLLocationDistance(8000)
        let mapCenter = CLLocationCoordinate2D(latitude: 47.2162055, longitude: -1.5494957)
        let mapRegion = MKCoordinateRegion.init(center: mapCenter, latitudinalMeters: locationRadius,longitudinalMeters: locationRadius)
        mapView.setRegion(mapRegion, animated: false)
        mapView.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Stations fetching
    
    func fetchLocalStations(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Station")
        
        do {
            stationArray = try context.fetch(fetchRequest) as! [Station]
        } catch {
            print("context could not save data")
        }
        
    }

    func addAllMapAnnotations(){
        for station in stationArray {
           mapView.addAnnotation(station)
        }
    }
    
    func refreshMapAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        addAllMapAnnotations()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "StationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
                let detailButton = UIButton(type: .detailDisclosure)
                detailButton.tintColor = UIColor.darkGray
                annotationView?.rightCalloutAccessoryView = detailButton
                annotationView?.canShowCallout = true
        }else {
            annotationView!.annotation = annotation
        }
        
        if let stationAnnotation = annotation as? Station {
            if displayMode == DisplayMode.Slots {
                annotationView?.glyphText = stationAnnotation.availableBikes
                annotationView?.markerTintColor = stationAnnotation.availableBikesColor
            } else {
                annotationView?.glyphText = stationAnnotation.availableSlots
                annotationView?.markerTintColor = stationAnnotation.availableSlotsColor
            }
            
        } else {
            print("Error : annotation is not a Station")
        }
       return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let station = view.annotation as? Station {
            selectedStation = station
            performSegue(withIdentifier: "showStationDetailSegue", sender: self)
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStationDetailSegue" {
            if let detailVC = segue.destination as? DetailViewController{
                detailVC.selectedStation = selectedStation
            }
        }
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == DisplayMode.Slots.rawValue {
            displayMode = DisplayMode.Slots
        } else {
            displayMode = DisplayMode.Bikes
        }
        refreshMapAnnotations()
    }
    
    
}

