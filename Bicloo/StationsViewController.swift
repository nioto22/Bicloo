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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: stationCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self   // Same as in storyBoard ctrl to StationView : delegate ...
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: stationCellIdentifier)
        
        cell!.textLabel?.text = stationList[indexPath.row]
        
        return cell!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

