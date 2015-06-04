//
//  BeaconManager.swift
//  ZKiBeacons
//
//  Created by Zeeshan Khan on 6/2/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconManager: NSObject, CLLocationManagerDelegate {
   
    let manager = CLLocationManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "BEACON_UUID"), identifier: "com.zeeshan.beacon")
    var arrRows: [BeaconModel] = []
    var arrInRange: [BeaconModel] = []
    let avgBar = -80
    
//    var beaconRegion: CLBeaconRegion {
//        let uuid = NSUUID(UUIDString: "BEACON_UUID")
//        return CLBeaconRegion(proximityUUID: uuid, identifier: "com.barclays.beacon")
//    }
    
    class  var sharedInstance: BeaconManager {
        struct Static {
            static var instance: BeaconManager?
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = BeaconManager()
        })
        return Static.instance!
    }
    
    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        beaconRegion.notifyEntryStateOnDisplay = true;
        beaconRegion.notifyOnEntry = true;
        beaconRegion.notifyOnExit = true;
        
        self.triggerLocationServices()
    }
    
    func triggerLocationServices() {
        println("isLocationServicesEnabled: \(CLLocationManager.locationServicesEnabled())")
        println("authorizationStatus: \(CLLocationManager.authorizationStatus().rawValue)")
        if manager.respondsToSelector("requestAlwaysAuthorization") {
            manager.requestAlwaysAuthorization() //requestWhenInUseAuthorization
        } else {
            startUpdatingLocation()
        }
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func startBeaconMonitoring() {
        if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) {
            manager.startMonitoringForRegion(beaconRegion)
        }
    }
    
    // MARK: - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        println("didDetermineState state: \(state.rawValue)")
        if state == .Inside {
            manager.startRangingBeaconsInRegion(beaconRegion)
        }
        else {
            manager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("didEnterRegion")
        manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("didExitRegion")
        manager.stopRangingBeaconsInRegion(beaconRegion)
    }

    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways { // which api to use for below iOS 8, this does not have in enum || status == .Authorized
            startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError: \(error)")
    }
    
//    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
//        println("didStartMonitoringForRegion")
//    }

    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println("monitoringDidFailForRegion")
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        println("didRangeBeacons\n")
        for beacon in beacons {
            let msg = "major: \(beacon.major), minor: \(beacon.minor), rssi: \(beacon.rssi)"
            println("       \(msg)")
            
            if beacon.rssi < 0 {
                
                var isFound = false
                var inRangeBeacons = arrInRange
                var id = "\(beacon.major)_\(beacon.minor)"
                
                for model in inRangeBeacons {
                    if model.id == id {
                        model.updateAvgRSSI(beacon as! CLBeacon)
                        isFound = true
                        break
                    }
                }
                
                if isFound == false {
                    arrInRange.append(BeaconModel(beacon: beacon as! CLBeacon))
                }
            }
        }

        updateTableItems()
    }

    func updateTableItems() {
        
        var isItemModified = false
        
        for var index = 0; index < arrInRange.count; ++index {
            let model = arrInRange[index]
            let avg = model.avgRSSI
            println("Avg: \(avg)")
            
            if contains(arrRows, model) {
                if avg < avgBar {
                    println("DELETE Row: \(model.id)")
                    arrRows.removeAtIndex(index)
                    isItemModified = true
                }
            }
            else {
                if avg > avgBar && avg < 0 {
                    println("ADD Row: \(model.id)")
                    arrRows.append(model as BeaconModel)
                    isItemModified = true
                    
                    if UIApplication.sharedApplication().applicationState != .Active {
                        println(" Show Local Notification: \(UIApplication.sharedApplication().applicationState)")
                        showNotification("New Beacon \(model.id)")
                    }
                }
            }
        }
        
        if isItemModified == true {
            // Refresh table
            println("Items modified, reloading table view...")
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let navCon = appDelegate.window!.rootViewController as! UINavigationController
            let viewController:ViewController =  navCon.viewControllers[0] as! ViewController
            viewController.arrBeacons = arrRows
            viewController.tableView!.reloadData()
        }
    }
    
    func showNotification(msg: String) {
        
        let ln = UILocalNotification()
        ln.alertAction = "ALERT"
        ln.alertBody = msg
        ln.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().presentLocalNotificationNow(ln)
    }
    
}
