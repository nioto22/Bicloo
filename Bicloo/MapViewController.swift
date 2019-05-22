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

class MapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var stationArray: [Station] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchLocalStations()
        addAllMapAnnotations()
        
        let locationRadius = CLLocationDistance(8000)
        let mapCenter = CLLocationCoordinate2D(latitude: 47.2162055, longitude: -1.5494957)
        let mapRegion = MKCoordinateRegion.init(center: mapCenter, latitudinalMeters: locationRadius,longitudinalMeters: locationRadius)
        mapView.setRegion(mapRegion, animated: false)
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

}
