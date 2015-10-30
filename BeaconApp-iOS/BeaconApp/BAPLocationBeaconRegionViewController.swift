//
//  BAPLocationBeaconRegionViewController.swift
//  BeaconApp
//
//  Created by 清 貴幸 on 2015/10/17.
//  Copyright © 2015年 PRH. All rights reserved.
//

import UIKit
import CoreLocation

class BAPLocationBeaconRegionViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion!
    var UUID: NSUUID? {
       return ProximityUUID.DEBUG.UUID
    }
    var ajiting = false
    let userNameKey = "BAPUserNameKey"
    
    @IBOutlet weak var regionStateLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.text = NSUserDefaults.standardUserDefaults().objectForKey(self.userNameKey) as? String ?? ""
        self.nameTextField.delegate = self
        
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
    
    func userName() -> String {
        if let name = NSUserDefaults.standardUserDefaults().objectForKey(self.userNameKey) as? String {
            return name
        }
        
        let name = self.nameTextField.text
        if name?.characters.count == 0 {
            return name!
        }
        
        return "名無しさん"
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if ajiting {
            return
        }
        
        self.regionStateLabel.text = "in"
        self.ajiting = true
        AJITOAPI.IN.post(name: self.userName())
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if !ajiting {
            return
        }
        
        self.regionStateLabel.text = "out"
        self.ajiting = false
        AJITOAPI.OUT.post(name: self.userName())
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        NSLog("inside: \(state == .Inside), outside: \(state == .Outside), unkown: \(state == .Unknown)")
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        self.locationManager.requestStateForRegion(self.beaconRegion)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.saveUserName(name: textField.text)
        return true
    }
    
    func saveUserName(name name: String?) {
        if name?.characters.count == 0 {
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(name, forKey: self.userNameKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    enum AJITOAPI: String {
        case IN = "/ajiting"
        case OUT = "/ajiting-out"
        
        var baseURLString: String {
            return "http://jewelpet.herokuapp.com/hubot"
        }
        
        var key: String {
            return "exYuTsKhZF6t2V"
        }
        
        func post(name name: String) {
            let request = NSMutableURLRequest(URL: NSURL(string: baseURLString + self.rawValue)!)
            request.HTTPMethod = "POST"
            request.HTTPBody = "user=\(name)&key=\(key)".dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            session.dataTaskWithRequest(request) { (_, response, error) -> Void in
                // TODO: エラーハンドリング
                NSLog("\(response!)")
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
