//
//  DetailViewController.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 21/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    var selectedStation: Station!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var availableBikesLabel: UILabel!
    @IBOutlet weak var availableSlotsLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedStation.name
        availableBikesLabel.text = (selectedStation.availableBikes ?? "0") + " vélos disponibles"
        availableSlotsLabel.text = (selectedStation.availableSlots ?? "0") + " places disponibles"
        mapView.addAnnotation(selectedStation)
        
        let locationRadius = CLLocationDistance(4000)
        let mapRegion = MKCoordinateRegionMakeWithDistance(selectedStation.coordinate, locationRadius,locationRadius)
        mapView.setRegion(mapRegion, animated: false)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let locationRadius = CLLocationDistance(1000)
        let mapRegion = MKCoordinateRegionMakeWithDistance(selectedStation.coordinate, locationRadius,locationRadius)
        mapView.setRegion(mapRegion, animated: true)
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

}
