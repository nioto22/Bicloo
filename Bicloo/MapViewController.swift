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
    
    func createStation(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Station", in: context)
        let station = NSManagedObject(entity: entity!, insertInto: context) as? Station
        
        station?.identifier = "43"
        station?.name = "Machine de l'île"
        station?.latitude = "47.206918"
        station?.longitude = "-1.564806"
        station?.adress = "3, boulevard Léon Bureau"
        station?.availableBikes = "17"
        station?.availableSlots = "19"
        station?.lastUpdate = Date() as NSDate
        station?.status = "OPEN"
        
        
        do {
            try context.save()
        } catch {
            print("context could not save data")
        }
    }
    
    func fetchLocalStations(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Station")
        
        do {
            stationArray = try context.fetch(fetchRequest) as! [Station]
        } catch {
            print("context could not save data")
        }
        
        if stationArray.count == 0 {
            createStation()
        }
    }

    func addAllMapAnnotations(){
        for station in stationArray {
           mapView.addAnnotation(station)
        }
    }

}
