//
//  FirstViewController.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 20/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//

import UIKit
import CoreData

class StationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    
    //let stationList: [String] = ["Machine de l'île","Hôtel de ville", "Palais des sports","Madeleine"]
    
    var stationArray: [Station] = []
    var selectedStation: Station!
    
    let stationCellIdentifier = "StationCellIdentifier"
    
    let stationsListUrl = URL(string: "https://api.jcdecaux.com/vls/v3/stations?contract=Nantes&apiKey=6bd1c235c5a42007ed686f25ddf9db11c43d6fb7")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.tableView.register(StationTableViewCell.self, forCellReuseIdentifier: stationCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self   // Same as in storyBoard ctrl to StationView : delegate ...
        
        refreshStationsList()
        fetchOnlineStation()
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
        cell.availableBikesLabel.text = (station.availableBikes ?? "0") + " vélos"
        cell.availableSlotsLabel.text = (station.availableSlots ?? "0") + " places"
        cell.distanceLabel.text = "212 m"
        
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
    
    func fetchOnlineStation(){
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
        

        for station in stationsArray {
            
            let newStation = NSManagedObject(entity: entity!, insertInto: context) as? Station
            
            if let identifier = station["number"] as? Int {
                newStation?.identifier = String(identifier)
            }
            if let name = station["name"] as? String {
            let nameRegex = try? NSRegularExpression(pattern: "#[0-9]*( )?-( )?", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, name.count)
            let formattedName = nameRegex?.stringByReplacingMatches(in: name, options: [], range: range, withTemplate: "")
            newStation?.name = formattedName
                
               
            }

            if let position = station["position"] as? [String: Any] {
                if let latitude = position["latitude"] as? Double {
                    newStation?.latitude = String(latitude)
                }
                if let longitude = position["longitude"] as? Double {
                    newStation?.longitude = String(longitude)
                }
            }
            if let address = station["address"] as? String {
                newStation?.address = address
            }
            if let mainStands = station["mainStands"] as? [String: Any] {
                if let availabilities = mainStands["availabilities"] as? [String: Any] {
                    if let availableBikes = availabilities["bikes"] as? Int {
                        newStation?.availableBikes = String(availableBikes)
                    }
                    if let availableSlots = availabilities["stands"] as? Int {
                        newStation?.availableSlots = String(availableSlots)
                    }
                }
            }
            if let lastUpdate = station["lastUpdate"] as? String {
                // let dateFormater = ISO8601DateFormatter() -> easiest way
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                if let date = dateFormatter.date(from: lastUpdate) {
                    newStation?.lastUpdate = date as NSDate
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
}

