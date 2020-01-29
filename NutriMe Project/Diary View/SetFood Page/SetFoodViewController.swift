//
//  SetFoodViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 01/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

protocol SaveData {
    func saveData(food: Food, eatCategory: EatCategory, portion: Float, date: Date)
    func dismissPage(dismiss: Bool)
}

class SetFoodViewController: UIViewController {
    
    var selectedSection: EatCategory?
    var selectedFood: UserFood?
    var totalPorsi: Float = 1.0
    
    var date = Date()
    var formatter = DateFormatter()
    var pickerCode: Int?
    var delegate : SaveData?
    
    let database = CKContainer.default().publicCloudDatabase
    let userID:String = UserDefaults.standard.value(forKey: "currentUserID") as! String
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveBtn(_ sender: Any) {
        
        let diaryRecord = CKRecord(recordType: "Diary")
        let selectedCategory = selectedSection.map{$0.rawValue}
        
        formatter.dateFormat = "EEEE, d MMM yyyy"
        
        let totalCalories = self.totalPorsi * (selectedFood?.calories ?? 0)
        let totalCarbohydrate = self.totalPorsi * (selectedFood?.makros?.carbohydrate ?? 0)
        let totalProtein = self.totalPorsi * (selectedFood?.makros?.protein ?? 0)
        let totalFat = self.totalPorsi * (selectedFood?.makros?.fat ?? 0)
        
//        print(totalCalories)
//        print(totalFat)
//        print(totalProtein)
//        print(totalCarbohydrate)
        
        diaryRecord.setValue(userID, forKey: "userID")
        diaryRecord.setValue(selectedFood?.ID, forKey: "foodID")
        diaryRecord.setValue(selectedFood?.name, forKey: "foodName")
        diaryRecord.setValue(totalCalories, forKey: "foodCalories")
        diaryRecord.setValue(totalCarbohydrate, forKey: "foodCarbohydrate")
        diaryRecord.setValue(totalFat, forKey: "foodFat")
        diaryRecord.setValue(totalProtein, forKey: "foodProtein")
        diaryRecord.setValue(totalPorsi, forKey: "portion")
        diaryRecord.setValue(formatter.string(from: date), forKey: "date")
        diaryRecord.setValue(selectedCategory, forKey: "category")
        
        self.database.save(diaryRecord) { (record, error) in
            if error == nil {
                print(record!.recordID.recordName)
                //Dismiss View
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "needUpdate")
                    
                    let db = DatabaseNutriMe()
                    guard let userID = UserDefaults.standard.value(forKey: "currentUserID") as? String else {return}
                    db.fetchDataUser(userID: userID, completion: { (userInfo) in
                        DispatchQueue.main.async {
                            
                            db.userInfo = userInfo
                           //self.getUserData()
                            db.getUserData {_,_ in 
                             DispatchQueue.main.async {
                                 if !UserDefaults.standard.bool(forKey: "isReportCreated"){
                                     db.createReportRecord()
                                 }else{
                                     if UserDefaults.standard.bool(forKey: "needUpdate"){
                                         db.updateReport()
                                         UserDefaults.standard.set(false, forKey: "needUpdate")
                                        print("test work")
                                        self.delegate?.dismissPage(dismiss: true)
                                        self.dismiss(animated: true)
                                     }
                                 }
                             }
                         }
                     }
                    })
                    
                    
//                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }
        }
    }
    
    @IBOutlet weak var detailTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTable.delegate = self
        detailTable.dataSource = self
        detailTable.tableFooterView = UIView()
        
        detailTable.isScrollEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPicker"{
            let vc = segue.destination as! PickerViewController
            vc.delegate = self
            vc.pickerCode = self.pickerCode
            vc.selectedCategory = self.selectedSection
        }
    }
    
}

extension SetFoodViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 && indexPath.row <= 3{
            self.pickerCode = indexPath.row
            performSegue(withIdentifier: "toPicker", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetail", for: indexPath) as! SetFoodTableViewCell
        
        if indexPath.row == 0{
            cell.lblName.text = selectedFood?.name
            cell.lblDetail.text = ""
        }else if indexPath.row == 1{
            cell.lblName.text = "\(totalPorsi) Portion"
            cell.lblDetail.text = "\(selectedFood!.calories * totalPorsi) Cal"
            cell.accessoryType = .disclosureIndicator
        }else if indexPath.row == 2{
            cell.lblName.text = selectedSection.map { $0.rawValue }
            cell.lblDetail.text = ""
            cell.accessoryType = .disclosureIndicator
        }else{
            formatter.dateFormat = "EEEE, d MMM yyyy"
            cell.lblName.text = formatter.string(from: date)
            cell.lblDetail.text = ""
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}

extension SetFoodViewController: DataTransfer{
    func getPortion(portion: Int) {
        self.totalPorsi = Float(portion)
        self.detailTable.reloadData()
    }
    
    func getDate(toDate: Date) {
        self.date = toDate
        self.detailTable.reloadData()
    }
    
    func getEatCategory(category: EatCategory) {
        self.selectedSection = category
        self.detailTable.reloadData()
    }
    
    
}
