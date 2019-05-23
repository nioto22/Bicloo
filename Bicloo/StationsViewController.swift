//
//  FirstViewController.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 20/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//

import UIKit
import CoreData
import NVActivityIndicatorView
import CoreLocation

class StationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    
    //let stationList: [String] = ["Machine de l'île","Hôtel de ville", "Palais des sports","Madeleine"]
    
    var stationArray: [Station] = []
    var selectedStation: Station!
    
    let stationCellIdentifier = "StationCellIdentifier"
    
    let stationsListUrl = URL(string: "https://api.jcdecaux.com/vls/v3/stations?contract=Nantes&apiKey=6bd1c235c5a42007ed686f25ddf9db11c43d6fb7")!
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.tableView.register(StationTableViewCell.self, forCellReuseIdentifier: stationCellIdentifier)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        tableView.dataSource = self
        tableView.delegate = self   // Same as in storyBoard ctrl to StationView : delegate ...
        
        activityIndicatorView.type = NVActivityIndicatorType.ballClipRotatePulse
        activityIndicatorView.color = UIColor.BiclooColor.Orange
        
        refreshStationsList()
        parseStationsJSON()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    // MARK: - Stations fetching
    
    
    func refreshStationsList(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Station")
        let sortDescriptor = NSSortDescriptor(key: "distance", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
        stationArray = try context.fetch(fetchRequest) as! [Station]
        } catch {
            print("context could not save data")
        }
        
        tableView.reloadData()
    }


    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: stationCellIdentifier) as! StationTableViewCell
        
        let station = stationArray[indexPath.row]
        
        cell.stationNameLabel.text = station.name
        cell.availableBikesLabel.text = station.availableBikesString
        cell.availableSlotsLabel.text = station.availableSlotsString
        cell.availableBikesLabel.backgroundColor = station.availableBikesColor
        cell.availableSlotsLabel.backgroundColor = station.availableSlotsColor
        cell.distanceLabel.text = String(station.distance)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStation = stationArray[indexPath.row]
        performSegue(withIdentifier: "showStationDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStationDetailSegue" {
            if let detailVC = segue.destination as? DetailViewController{
                detailVC.selectedStation = selectedStation
            }
        }
    }
    
    // MARK: - HTTP Request
    
    func parseStationsJSON(){
        
        if stationArray.count == 0 {
            activityIndicatorView.startAnimating()
        }
        
        let session = URLSession.shared
        let getOnlineStations = session.dataTask(with: stationsListUrl) { (data, response, error) in
            
            if error != nil {
                print("Error in http task getOnlineStations")
                print(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
                else {
                    print("http status code is not ok in FetchOnlineStation")
                    print(response)
                    return
            }
            
            guard let mime = response?.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: [])
                guard let stationsJsonArray = jsonResponse as? [[String: Any]] else {
                    return
                }
                DispatchQueue.main.async {
                    self.saveStationsInLocal(stationsArray: stationsJsonArray)
                }
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
         
        }
        getOnlineStations.resume()
    }
    
    
    func saveStationsInLocal(stationsArray: [[String: Any]]){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Station", in: context)
        

        for stationDict in stationsArray {
            
            
            
            guard let stationNumber = stationDict["number"] as? Int else {
                continue
            }
            
            var station = stationAlreadyExists(identifier: String(stationNumber))
            if station == nil {
                station = NSManagedObject(entity: entity!, insertInto: context) as? Station
                station?.identifier = String(stationNumber)
            }
            
            
            
            if let name = stationDict["name"] as? String {
            let nameRegex = try? NSRegularExpression(pattern: "#[0-9]*( )?-( )?", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, name.count)
            let formattedName = nameRegex?.stringByReplacingMatches(in: name, options: [], range: range, withTemplate: "")
            station?.name = formattedName
                
               
            }

            if let position = stationDict["position"] as? [String: Any] {
                if let latitude = position["latitude"] as? Double {
                    station?.latitude = String(latitude)
                }
                if let longitude = position["longitude"] as? Double {
                    station?.longitude = String(longitude)
                }
            }
            if let address = stationDict["address"] as? String {
                station?.address = address
            }
            if let mainStands = stationDict["mainStands"] as? [String: Any] {
                if let availabilities = mainStands["availabilities"] as? [String: Any] {
                    if let availableBikes = availabilities["bikes"] as? Int {
                        station?.availableBikes = String(availableBikes)
                    }
                    if let availableSlots = availabilities["stands"] as? Int {
                        station?.availableSlots = String(availableSlots)
                    }
                }
            }
            if let lastUpdate = stationDict["lastUpdate"] as? String {
                // let dateFormater = ISO8601DateFormatter() -> easiest way
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                if let date = dateFormatter.date(from: lastUpdate) {
                    station?.lastUpdate = date as NSDate
                }
            }
            
        }

        do {
            try context.save()
        } catch {
            print("context could not save data")
        }
        refreshStationsList()
    }
    
    func stationAlreadyExists(identifier: String) -> Station?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Station")
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        do {
            stationArray = try context.fetch(fetchRequest) as! [Station]
            
            if (stationArray.count > 0){
                return stationArray.first
            }
        } catch {
            print("context could not save data")
        }
        return nil
    }
    
    // MARK: - UserLocation
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        if (locations.count > 0){
        userLocation = locations.last
        }
        
        for station in stationArray {
            let stationLocation = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude)
            if let stationDistance = self.userLocation?.distance(from: stationLocation){
                station.distance = Double(lround(stationDistance))
            } else {
                station.distance = 0
            }
        }
        
        let sortedStations = stationArray.sorted(by: {$0.distance < $1.distance})
        stationArray = sortedStations
        tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        userLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("locationManager didChangeAuthorization")
        print(status)
    }

    
}

