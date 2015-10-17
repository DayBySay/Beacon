//
//  BAPLocationBeaconRegionViewController.swift
//  BeaconApp
//
//  Created by 清 貴幸 on 2015/10/17.
//  Copyright © 2015年 PRH. All rights reserved.
//

import UIKit
import CoreLocation

class BAPLocationBeaconRegionViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    @IBOutlet weak var regionStateLabel: UILabel!
    var beaconRegion: CLBeaconRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        
        if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.classForCoder()) == false {
            print("この端末ではBLEが使えません")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            return
        }
        
        let UUIDString = "00000000-1D19-1001-B000-001C4DD99A25";
        guard let UUID = NSUUID(UUIDString: UUIDString) else {
            print("UUIDの初期化に失敗しました")
            return
        }
        
        self.beaconRegion = CLBeaconRegion(proximityUUID: UUID, identifier: "ajito")
        
        self.locationManager.startMonitoringForRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
       self.regionStateLabel.text = "in"
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
       self.regionStateLabel.text = "out"
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        print("inside: \(state == .Inside), outside: \(state == .Outside), unkown: \(state == .Unknown)")
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        self.locationManager.requestStateForRegion(self.beaconRegion)
    }
}
