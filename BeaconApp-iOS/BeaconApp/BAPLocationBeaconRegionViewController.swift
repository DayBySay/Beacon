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
    var beaconRegion: CLBeaconRegion!
    var UUID: NSUUID? {
       return ProximityUUID.DEBUG.UUID
    }
    
    @IBOutlet weak var regionStateLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
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
        
        guard let UUID = self.UUID else {
            print("UUIDの初期化に失敗しました")
            return
        }
        
        self.beaconRegion = CLBeaconRegion(proximityUUID: UUID, identifier: "ajito")
        
        self.locationManager.startMonitoringForRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.regionStateLabel.text = "in"
        AJITOAPI.IN.post(name: self.nameTextField.text)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
       self.regionStateLabel.text = "out"
        AJITOAPI.OUT.post(name: self.nameTextField.text)
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        print("inside: \(state == .Inside), outside: \(state == .Outside), unkown: \(state == .Unknown)")
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        self.locationManager.requestStateForRegion(self.beaconRegion)
    }
    
    enum AJITOAPI: String {
        case IN = "/ajiting"
        case OUT = "/ajiting-out"
        
        var baseURLString: String {
            return "http://jewelpet.herokuapp.com/hubot/"
        }
        
        var key: String {
            return "exYuTsKhZF6t2V"
        }
        
        func post(name name: String?) {
            let name = name ?? "名無しさん"
            let request = NSMutableURLRequest(URL: NSURL(string: baseURLString + self.rawValue)!)
            request.HTTPMethod = "POST"
            request.HTTPBody = "user=\(name)&key=\(key)".dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            session.dataTaskWithRequest(request) { (_, response, error) -> Void in
                // TODO: エラーハンドリング
            }.resume()
        }
    }
    
    enum ProximityUUID: String {
        case DEBUG = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
        case AJITO = "00000000-1D19-1001-B000-001C4DD99A25"
        case JUN = "B0FC4601-14A6-43A1-ABCD-CB9CFDDB4013"
        
        var UUID: NSUUID? {
            return NSUUID(UUIDString: self.rawValue)
        }
    }
}
