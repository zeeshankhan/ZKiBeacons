//
//  ViewController.swift
//  ZKiBeacons
//
//  Created by Zeeshan Khan on 6/2/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView?
    var arrBeacons: [BeaconModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        BeaconManager.sharedInstance.startBeaconMonitoring()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBeacons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Basic", forIndexPath: indexPath) as? UITableViewCell

        let model: BeaconModel = arrBeacons[indexPath.row]
        let beacon = model.beacon
        
        let detailLabel:String = "Major: \(beacon!.major.integerValue), " +
            "Minor: \(beacon!.minor.integerValue), " +
        "RSSI: \(beacon!.rssi as Int), " // + "UUID: \(beacon.proximityUUID.UUIDString)"
        cell!.textLabel!.text = detailLabel

        return cell!
        
    }
}

extension ViewController: UITableViewDelegate {}

