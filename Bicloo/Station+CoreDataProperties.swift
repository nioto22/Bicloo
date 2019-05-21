//
//  Station+CoreDataProperties.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 21/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//
//

import Foundation
import CoreData


extension Station {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Station> {
        return NSFetchRequest<Station>(entityName: "Station")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var adress: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var status: String?
    @NSManaged public var lastUpdate: NSDate?
    @NSManaged public var availableBikes: String?
    @NSManaged public var availableSlots: String?

}
