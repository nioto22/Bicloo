//
//  SationTableViewCell.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 21/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var availableBikesLabel: UILabel!
    
    @IBOutlet weak var availableSlotsLabel: UILabel!
    
    @IBOutlet weak var stationNameLabel: UILabel!
    

    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        availableBikesLabel.backgroundColor = UIColor(red: 0, green: 143/255, blue: 0, alpha: 1)
        availableSlotsLabel.backgroundColor = UIColor(red: 0, green: 143/255, blue: 0, alpha: 1)
        
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        availableBikesLabel.backgroundColor = UIColor(red: 0, green: 143/255, blue: 0, alpha: 1)
        availableSlotsLabel.backgroundColor = UIColor(red: 0, green: 143/255, blue: 0, alpha: 1)
        
    }

}
