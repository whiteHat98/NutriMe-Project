//
//  PantanganMakananViewController.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 13/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

class PantanganMakananViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let allergies = ["Kacang", "Gandum", "Kedelai", "Telur", "Susu Sapi", "Ikan", "Udang"]
    let restrictions = ["Vegetarian", "Gluten Free"]
    var userRestrictions: [String] = []
    
    var userInfo : UserInfo?
    let database = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if isMovingFromParent{
            updateRecord()
        }
    }
    
    func updateRecord() {
        let recordID = CKRecord.ID(recordName: userInfo!.userID)
        
        database.fetch(withRecordID: recordID) { (record, error) in
            if error == nil {
                record?.setValue(self.userRestrictions ,forKey: "restrictions")
                
                self.database.save(record!) { (record, error) in
                    if error == nil {
                        print("Record Updated")
                        self.userInfo?.foodRestrictions = self.userRestrictions
                    }
                    else{
                        print("Record not updated")
                    }
                    
                }
            }
            else{
                print("No data with id \(recordID)")
            }
            
        }
    }

}

extension PantanganMakananViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return restrictions.count
        }
        else {
            return allergies.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Pantangan Makanan"
        }
        else {
            return "Alergi Makanan"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestrictionCell", for: indexPath) as! PantanganMakananTableViewCell
        
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
            cell.textLbl.text = restrictions[indexPath.row]
        }
        else{
            print(indexPath.row)
            cell.textLbl.text = allergies[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            if indexPath.section == 0 {
                for (i, restriction) in userRestrictions.enumerated() {
                    if restriction == restrictions[indexPath.row] {
                        userRestrictions.remove(at: i)
                    }
                }
            }
            else {
                for (i, restriction) in userRestrictions.enumerated() {
                    if restriction == allergies[indexPath.row] {
                        userRestrictions.remove(at: i)
                    }
                }
            }
        }
        else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            if indexPath.section == 0 {
                userRestrictions.append(restrictions[indexPath.row])
            }
            else{
                userRestrictions.append(allergies[indexPath.row])
            }
        }
        print(userRestrictions)
        
    }
    
}
