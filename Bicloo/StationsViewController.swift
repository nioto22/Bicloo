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

class StationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchResultsUpdating{

    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    
    //let stationList: [String] = ["Machine de l'île","Hôtel de ville", "Palais des sports","Madeleine"]
    
    var stationsArray: [Station] = []
    var selectedStation: Station!
    
    
    let stationCellIdentifier = "StationCellIdentifier"
    
    let stationsListUrl = URL(string: "https://api.jcdecaux.com/vls/v3/stations?contract=Nantes&apiKey=6bd1c235c5a42007ed686f25ddf9db11c43d6fb7")!
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredStationsArray: [Station] = []
    
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
        
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Rechercher une station"
        
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
        stationsArray = try context.fetch(fetchRequest) as! [Station]
        } catch {
            print("context could not save data")
        }
        
        tableView.reloadData()
    }


    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActivated() ? filteredStationsArray.count : stationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: stationCellIdentifier) as! StationTableViewCell
        let station = isSearchActivated() ? filteredStationsArray[indexPath.row] : stationsArray[indexPath.row]
        
        cell.stationNameLabel.text = station.name
        cell.availableBikesLabel.text = station.availableBikesString
        cell.availableSlotsLabel.text = station.availableSlotsString
        cell.availableBikesLabel.backgroundColor = station.availableBikesColor
        cell.availableSlotsLabel.backgroundColor = station.availableSlotsColor
        cell.distanceLabel.text = station.distanceString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStation = isSearchActivated() ? filteredStationsArray[indexPath.row] : stationsArray[indexPath.row]
        performSegue(withIdentifier: "showStationDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStationDetailSegue" {
            if let detailVC = segue.destination as? DetailViewController{
                detailVC.selectedStation = selectedStation
            }
        }
    }
    
    // MARK: - UISearchController
    
    func filterContent(for searchText: String) {
        // Update the searchResults array with matches
        // in our entries based on the title value.
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredStationsArray = stationsArray.filter{
                station in
                return (station.name?.lowercased().contains(searchText.lowercased()) ?? nil)!
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            // Reload the table view with the search result data.
            tableView.reloadData()
        }
    }
    
    func isSearchActivated() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    
    // MARK: - HTTP Request
    
    func parseStationsJSON(){
        
        if stationsArray.count == 0 {
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
                // Add here method pull to refresh
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
            stationsArray = try context.fetch(fetchRequest) as! [Station]
            
            if (stationsArray.count > 0){
                return stationsArray.first
            }
        } catch {
            print("context could not save data")
        }
        return nil
    }

    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        if (locations.count > 0){
        userLocation = locations.last
        }
        
        for station in stationsArray {
            let stationLocation = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude)
            if let stationDistance = self.userLocation?.distance(from: stationLocation){
                station.distance = Double(lround(stationDistance))
            } else {
                station.distance = 0
            }
        }
        
        let sortedStations = stationsArray.sorted(by: {$0.distance < $1.distance})
        stationsArray = sortedStations
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

