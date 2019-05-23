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
        return address
    }
    
    public var distanceString: String?{
        if (distance == 0.0){
            return ""
        } else if distance >= 1000 {
            return String(format: "%.1f km", distance/1000)
        }
        return String(format: "%.f m", distance)
    
    }
    
    public var availableBikesColor: UIColor {
        if availableBikes != nil {
            if let availableBikesInt = Int(availableBikes!){
                switch availableBikesInt {
                case 0:
                    return UIColor.BiclooColor.Red
                case 1...3:
                    return UIColor.BiclooColor.Orange
                default:
                    return UIColor.BiclooColor.Green
                }
            }
        }
        return UIColor.BiclooColor.Green
    }
    
    public var availableSlotsColor: UIColor {
        if availableSlots != nil {
            if let availableSlotsInt = Int(availableSlots!){
                switch availableSlotsInt {
                case 0:
                    return UIColor.BiclooColor.Red
                case 1...3:
                    return UIColor.BiclooColor.Orange
                default:
                    return UIColor.BiclooColor.Green
                }
            }
        }
        return UIColor.BiclooColor.Green
    }
    
    public var availableBikesString: String{
        if availableBikes != nil {
            if let availableBikesInt = Int(availableBikes!){
                if availableBikesInt >= 2 {
                    return availableBikes! + " vélos"
                } else {
                    
                    return availableBikes! + " vélo"
                }
            }
        }
        return "0 vélo"
    }
    
    public var availableSlotsString: String {
        if availableSlots != nil {
            if let availableSlotsInt = Int(availableSlots!){
                if availableSlotsInt >= 2 {
                    return availableSlots! + " places"
                } else {
                    
                    return availableSlots! + " place"
                }
            }
        }
        return "0 place"
    }
    
    public var availableBikesLongString: String{
        if availableBikes != nil {
            if let availableBikesInt = Int(availableBikes!){
                if availableBikesInt >= 2 {
                    return availableBikes! + " vélos disponibles"
                } else {
                    
                    return availableBikes! + " vélo disponible"
                }
            }
        }
        return "0 vélo disponible"
    }
    
    public var availableSlotsLongString: String {
        if availableSlots != nil {
            if let availableSlotsInt = Int(availableSlots!){
                switch availableSlotsInt {
                case 0...1:
                    return availableSlots! + " place disponible"
                default:
                    return availableSlots! + " places disponibles"
                }
            }
        }
        return "0 place disponible"
    }
}
