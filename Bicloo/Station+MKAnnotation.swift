//
//  Station+CoreDataClass.swift
//  Bicloo
//
//  Created by Baptiste Alexandre on 21/05/2019.
//  Copyright © 2019 Nioto. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

extension Station: MKAnnotation {
    
    //station.latitude, st
    
    public var coordinate: CLLocationCoordinate2D {
        
        // Optionnals
        // input String? -> test if nil
        guard let latitude = latitude, let longitude = longitude
            else {
                // guard sort de la fonction ou réalise le else puis sort de la fonction
                return CLLocationCoordinate2DMake(47.2162055, -1.5494957)
        }
        
        // input: String (contains value) -> Test if CLLocationDegrees type
        guard let latDegrees = CLLocationDegrees(latitude), let lonDegrees = CLLocationDegrees(longitude)   else {
            return CLLocationCoordinate2DMake(47.2162055, -1.5494957)
        }
    
        return CLLocationCoordinate2DMake(latDegrees, lonDegrees)
    }
    
    public var title: String? {
        return name
    }
    
    public var subtitle: String?{
        return adress
    }
    
}
