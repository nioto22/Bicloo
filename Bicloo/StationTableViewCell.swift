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
        let availableBikesColor = availableBikesLabel.backgroundColor
        let availableSlotsColor = availableSlotsLabel.backgroundColor
        super.setSelected(selected, animated: animated)
        availableBikesLabel.backgroundColor = availableBikesColor
        availableSlotsLabel.backgroundColor = availableSlotsColor
        
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let availableBikesColor = availableBikesLabel.backgroundColor
        let availableSlotsColor = availableSlotsLabel.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        availableBikesLabel.backgroundColor = availableBikesColor
        availableSlotsLabel.backgroundColor = availableSlotsColor
    }

}
