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
    
    
    
    let stationList: [String] = ["Machine de l'île","Hôtel de ville", "Palais des sports","Madeleine"]
    
    var stationArray: [Station] = []
    var selectedStation: Station!
    
    let stationCellIdentifier = "StationCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.tableView.register(StationTableViewCell.self, forCellReuseIdentifier: stationCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self   // Same as in storyBoard ctrl to StationView : delegate ...
        
        fetchLocalStations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
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
    
    
}

