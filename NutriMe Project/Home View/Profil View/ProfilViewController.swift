//
//  ProfilViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 15/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

struct User{
    var name : String
    var weight : Int
    var height : Int
    var dob : String
    var test: String?
}

class ProfilViewController: UIViewController {
    
    @IBOutlet weak var logOutBtn: UIButton!
    @IBAction func logOutAction(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "userInfoExist")
        self.navigationController?.popToRootViewController(animated: false)
    }
    

    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var profilTableView: UITableView!
    
    let profilData = ["Name","Date of birth","Weight","Height"]
    let settings = ["Food Restrictions","Reminders"]
    
    var userInfo: UserInfo?
    
    var userData:[String] = []
    
    var formatter = DateFormatter()
    
    let database = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "dd MMMM yyyy"
//        userData = [userInfo!.name, "\(formatter.string(from: userInfo!.dob))", "\(userInfo!.weight)", "\(userInfo!.height)"]
        
        profilTableView.delegate = self
        profilTableView.dataSource = self
        profilTableView.isScrollEnabled = false
        profilTableView.tableFooterView = UIView()
        
        profilTableView.isScrollEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToEditProfile" {
            let nextVC = segue.destination as! editProfileViewController
            nextVC.userInfo = self.userInfo
        }
        else if segue.identifier == "segueToPantanganMakanan" {
            let nextVC = segue.destination as! PantanganMakananViewController  
            nextVC.userInfo = self.userInfo
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        userData = [userInfo!.name, "\(formatter.string(from: userInfo!.dob))", "\(userInfo!.weight)", "\(userInfo!.height)"]
        updateUserInfo()
    }
    
    func updateUserInfo() {
        let userID:String = UserDefaults.standard.value(forKey: "currentUserID") as! String
        
        let record = CKRecord.ID(recordName: userID)
        
        database.fetch(withRecordID: record) { (data, err) in
            if err != nil{
                print("No Data")
            }
            else{
                let name = data?.value(forKey: "name") as! String
                let gender = data?.value(forKey: "gender") as! String
                let dob = data?.value(forKey: "dob") as! String
                let weight = data?.value(forKey: "weight") as! Float
                let height = data?.value(forKey: "height") as! Float
                let caloriesGoal = data?.value(forKey: "caloriesGoal") as? Float
                let carbohydrateGoal = data?.value(forKey: "carbohydrateGoal") as? Float
                let fatGoal = data?.value(forKey: "fatGoal") as? Float
                let proteinGoal = data?.value(forKey: "proteinGoal") as? Float
                let mineralGoal = data?.value(forKey: "proteinGoal") as? Float
                let restrictions = data?.value(forKey: "restrictions") as? [String]
                
                //                self.userInfo = UserInfo(userID: userID, name: name, dob: stringToDate(dob), gender: gender, height: height , weight: weight , currCalories: 0, caloriesNeed: caloriesGoal!, activities: nil, foodRestriction: nil, reminder: nil, caloriesGoal: caloriesGoal!, carbohydrateGoal: carbohydrateGoal, fatGoal: fatGoal, proteinGoal: proteinGoal, mineralGoal: mineralGoal)
                self.userInfo = UserInfo(userID: userID, name: name, dob: stringToDate(dob), gender: gender, height: height, weight: weight, currCalories: 0, currCarbo: 0, currProtein: 0, currFat: 0, currMineral: 0, activityCalories: 0, foodRestrictions: restrictions, caloriesGoal: caloriesGoal, carbohydrateGoal: carbohydrateGoal, fatGoal: fatGoal, proteinGoal: proteinGoal, mineralGoal: mineralGoal)
                
                self.userData = [self.userInfo!.name, "\(self.formatter.string(from: self.userInfo!.dob))", "\(self.userInfo!.weight)", "\(self.userInfo!.height)"]
                DispatchQueue.main.async {
                    self.profilTableView.reloadData()
                }
            }
        }
    }
}

extension ProfilViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profilData.count + settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfil", for: indexPath)
        
        cell.selectionStyle = .none
        
        if indexPath.row > 3{
            cell.textLabel?.text = settings[indexPath.row - 4]
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
            return cell
        }else{
            cell.textLabel?.text = profilData[indexPath.row]
            cell.detailTextLabel?.text = userData[indexPath.row]
            cell.accessoryType = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            performSegue(withIdentifier: "segueToPantanganMakanan", sender: self)
        }
        else if indexPath.row == 5 {
            performSegue(withIdentifier: "segueToReminders", sender: self)
        }

    }
}
