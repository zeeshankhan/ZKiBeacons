//
//  BeaconModel.swift
//  ZKiBeacons
//
//  Created by Zeeshan Khan on 6/3/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconModel: NSObject {
    var beacon: CLBeacon?
    var arrRSSI: [Int] = []
    var avgRSSI = 0
    var id: String = ""
    let lenArrRSSI = 5
    
    init(beacon: CLBeacon) {
        self.beacon = beacon;
        id = "\(beacon.major)_\(beacon.minor)"
    }
    
    func updateAvgRSSI(beacon: CLBeacon) {
        if beacon.proximity != .Unknown {
            if arrRSSI.count >= lenArrRSSI {
                arrRSSI.removeAtIndex(0)
            }
            else {
                arrRSSI.append(beacon.rssi)
            }
            
            var total = 0
            for rssi in arrRSSI {
                total = total + rssi
            }
            
            var avg: Double = Double(total / arrRSSI.count)
            avg = floor(avg*100.0) / 100.0
            avgRSSI = Int(avg)
            
            println("[Beacon Model]: ID: \(id), Accuracy: \(beacon.accuracy), Proximity: \(beacon.proximity), Total: \(total), Avg: \(avgRSSI)")
        }
    }
}
