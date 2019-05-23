//
//  DetailViewController.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 21/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {

    var selectedStation: Station!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var availableBikesLabel: UILabel!
    @IBOutlet weak var availableSlotsLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedStation.name
        availableBikesLabel.text = selectedStation.availableBikesLongString
        availableSlotsLabel.text = selectedStation.availableSlotsLongString
        availableBikesLabel.backgroundColor = selectedStation.availableBikesColor
        availableSlotsLabel.backgroundColor = selectedStation.availableSlotsColor
        mapView.addAnnotation(selectedStation)
    
        
        let locationRadius = CLLocationDistance(4000)
        let mapRegion = MKCoordinateRegion.init(center: selectedStation.coordinate, latitudinalMeters: locationRadius,longitudinalMeters: locationRadius)
        mapView.setRegion(mapRegion, animated: false)
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let locationRadius = CLLocationDistance(1000)
        let mapRegion = MKCoordinateRegion.init(center: selectedStation.coordinate, latitudinalMeters: locationRadius,longitudinalMeters: locationRadius)
        mapView.setRegion(mapRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Prevents the userLocation blue Annotation to be customized as station
        guard annotation is Station else {return nil}
        
        let identifier = "StationAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            annotationView?.canShowCallout = false
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }else {
            annotationView!.annotation = annotation
        }
        
        if let stationAnnotation = annotation as? Station {
            annotationView?.glyphText = stationAnnotation.availableBikes
            annotationView?.markerTintColor = stationAnnotation.availableBikesColor
        } else {
            print("Error : annotation is not a Station")
        }
        return annotationView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
