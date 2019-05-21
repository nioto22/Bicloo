//
//  FirstViewController.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 20/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//

import UIKit

class StationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    
    let stationList: [String] = ["Machine de l'île","Hôtel de ville", "Palais des sports","Madeleine"]
    let stationCellIdentifier = "StationCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.tableView.register(StationTableViewCell.self, forCellReuseIdentifier: stationCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self   // Same as in storyBoard ctrl to StationView : delegate ...
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: stationCellIdentifier) as! StationTableViewCell
        
//        @IBOutlet weak var availableBikesLabel: UILabel!
//        @IBOutlet weak var availableSlotsLabel: UILabel!
//        @IBOutlet weak var stationNameLabel: UILabel!
//        @IBOutlet weak var distanceLabel: UIView!
        //cell!.textLabel?.text = stationList[indexPath.row]
        
        cell.stationNameLabel.text = stationList[indexPath.row]
        cell.availableBikesLabel.text = "20 vélos"
        cell.availableSlotsLabel.text = "43 places"
        cell.distanceLabel.text = "212 m"
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

