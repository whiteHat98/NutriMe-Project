//
//  DatabaseNutriMe.swift
//  NutriMe Project
//
//  Created by Randy Noel on 17/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class DatabaseNutriMe{
    
    var userInfo : UserInfo!
    var totalCarbohidrates: Double
    var totalCalories : Double
    var totalFat : Double
    var totalProtein: Double
    var diaryID: [String] = []
    let database = CKContainer.default().publicCloudDatabase
    
    init() {
        self.totalFat = 0
        self.totalProtein = 0
        self.totalCalories = 0
        self.totalCarbohidrates = 0
    }
    
    func fetchDataUser(userID : String,completion: @escaping(UserInfo) -> ()){
        //FETCH DATA
        var userTemp: UserInfo?
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
             
                userTemp = UserInfo(userID: userID, name: name, dob: stringToDate(dob), gender: gender, height: height, weight: weight, currCalories: 0, currCarbo: 0, currProtein: 0, currFat: 0, currMineral: 0, activityCalories: 0, foodRestrictions: restrictions, caloriesGoal: caloriesGoal, carbohydrateGoal: carbohydrateGoal, fatGoal: fatGoal, proteinGoal: proteinGoal, mineralGoal: mineralGoal)
                
                DispatchQueue.main.async {
                    completion(userTemp!)
                }
            }
        }
    }
    
    func getUserData(completion : @escaping(_ String: [CKRecord]?, _ error: Error?) -> Void){
        self.totalFat = 0
        self.totalProtein = 0
        self.totalCalories = 0
        self.totalCarbohidrates = 0
        if let dataDate = UserDefaults.standard.object(forKey: "reportDate") as? Date{
            if !Calendar.current.isDateInToday(dataDate) && UserDefaults.standard.bool(forKey: "isReportCreated"){
                UserDefaults.standard.set(false, forKey: "isReportCreated")
                print("Masuk!")
            }
            // cek data report
        }
        
        let userID:String = UserDefaults.standard.value(forKey: "currentUserID") as! String
        //let database = CKContainer.default().publicCloudDatabase
        let predicate1 = NSPredicate(format: "userID == %@", userID)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        let predicate2 = NSPredicate(format: "date == %@", formatter.string(from: Date()))
        let predicate3 = NSPredicate(format: "date == %@", Date() as NSDate)
        let predicates = [predicate1, predicate2]
        let predicates2 = [predicate1, predicate3]
        
        
        let diaryQuery = CKQuery(recordType: "Diary", predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        
        database.perform(diaryQuery, inZoneWith: nil) { (records, err) in
            if err != nil{
                print(err)
                completion(nil, err)
            }else{
                for data in records!{
                    if var diaryID = self.diaryID as? [String]{
                        diaryID.append(data.recordID.recordName)
                    }
                    self.totalCalories += data.value(forKey: "foodCalories") as! Double
                    self.totalCarbohidrates += data.value(forKey: "foodCarbohydrate") as! Double
                    self.totalProtein += data.value(forKey: "foodProtein") as! Double
                    self.totalFat += data.value(forKey: "foodFat") as! Double
                }
//                DispatchQueue.main.async {
//                    //self.currentCaloriesLabel.text = "\(Int(self.totalCalories))"
//
//                    if !UserDefaults.standard.bool(forKey: "isReportCreated"){
//                        self.createReportRecord()
//                    }else{
//                        self.updateReport()
//                        print("update!")
//                    }
        //}
                completion(records!, nil)
            }
        }
    }
    
    func updateReport(){
        guard let id = UserDefaults.standard.string(forKey: "todayReportRecordID") else { return }
        let recordName = UserDefaults.standard.string(forKey: "todayReportRecordID")
        let reportRecord = CKRecord.init(recordType: "Report", recordID: CKRecord.ID.init(recordName: recordName ?? "test"))
        reportRecord.setValue(self.userInfo.userID, forKey: "userID")
        reportRecord.setValue(self.userInfo.caloriesGoal, forKey: "caloriesGoal")
        reportRecord.setValue(self.userInfo.carbohydrateGoal, forKey: "carbohydrateGoal")
        reportRecord.setValue(self.userInfo.fatGoal, forKey: "fatGoal")
        reportRecord.setValue(self.userInfo.proteinGoal, forKey: "proteinGoal")
        reportRecord.setValue(self.totalCalories, forKey: "userCalories")
        reportRecord.setValue(self.totalCarbohidrates, forKey: "userCarbohydrates")
        reportRecord.setValue(self.totalFat, forKey: "userFat")
        reportRecord.setValue(self.totalProtein, forKey: "userProtein")
        reportRecord.setValue(self.diaryID, forKey: "diaryID")
        reportRecord.setValue("", forKey: "notes")
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        reportRecord.setValue(Date(), forKey: "date")
        
        self.database.delete(withRecordID: CKRecord.ID(recordName: recordName!)) { (record, err) in
            if err != nil{
                print(err)
            }
        }
        
        self.database.save(reportRecord) { (record, err) in
            if err != nil{
                print("ini err: \(err)")
            }
            else{
                print("report updated!")
            }
        }
    }
    
    func createReportRecord(){
        let reportRecord = CKRecord(recordType: "Report")
        
        reportRecord.setValue(self.userInfo.userID, forKey: "userID")
        reportRecord.setValue(self.userInfo.caloriesGoal, forKey: "caloriesGoal")
        reportRecord.setValue(self.userInfo.carbohydrateGoal, forKey: "carbohydrateGoal")
        reportRecord.setValue(self.userInfo.fatGoal, forKey: "fatGoal")
        reportRecord.setValue(self.userInfo.proteinGoal, forKey: "proteinGoal")
        reportRecord.setValue(self.totalCalories, forKey: "userCalories")
        reportRecord.setValue(self.totalCarbohidrates, forKey: "userCarbohydrates")
        reportRecord.setValue(self.totalFat, forKey: "userFat")
        reportRecord.setValue(self.totalProtein, forKey: "userProtein")
        reportRecord.setValue(self.diaryID, forKey: "diaryID")
        reportRecord.setValue("", forKey: "notes")
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        reportRecord.setValue(Date(), forKey: "date")
        self.database.save(reportRecord) { (record, err) in
            if err != nil{
                print(err)
            }
            else{
                UserDefaults.standard.set(true, forKey: "isReportCreated")
                UserDefaults.standard.set(record?.recordID.recordName, forKey: "todayReportRecordID")
                UserDefaults.standard.set(Date(), forKey: "reportDate")
                print("report created!")
            }
        }
    }
    
}
