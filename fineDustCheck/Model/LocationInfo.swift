//
//  LocationInfo.swift
//  fineDustCheck
//
//  Created by 서민영 on 2023/09/12.
//

import Foundation

class LocationInfo {
    
    static let shared = LocationInfo()
    
    var nowLocationName: String?
    var longitude: Double?
    var latitude: Double?
    var pmValue : String?
    var pmGradeValue: String?
    var dataTime: String?
    var stationName: String?
 

    private init() { }
}
