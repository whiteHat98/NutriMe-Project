//
//  DiaryViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 18/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import CloudKit


enum EatCategory: String{
    
    case pagi = "Sarapan"
    case siang = "Makan Siang"
    case malam = "Makan Malam"
    
}

class DiaryViewController: UIViewController {
    
    var foodList:[(food: String, calorie: Float)]=[("Nasi", 10),("Apple",12),("Nanas", 6),("Salmon",20)]
    var foodEaten:[FoodInDiary] = []
    var category:[EatCategory] = [.pagi, .siang, .malam]
    var dataDiary:[Diary] = []
    var selectedSection: EatCategory?
    
    var diaryPagi: Diary!
    var diarySiang: Diary!
    var diaryMalam: Diary!
    
    let database = CKContainer.default().publicCloudDatabase
    
    @IBOutlet weak var lblKetHari: UILabel!
    @IBOutlet weak var diaryTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (food,calorie) in foodList{
            let eat = FoodInDiary(category: .pagi, food: Food(name: food, calorie: calorie), date: Date(), portion: 1)
            foodEaten.append(eat)
        }
        
        if foodEaten.count>0{
            
            diaryPagi = Diary(category: .pagi, foods: foodEaten)
            diarySiang = Diary(category: .siang, foods: foodEaten)
            let foods:[FoodInDiary]=[]
            diaryMalam = Diary(category: .malam, foods: foods)
            
            setDiary(arrayDiary: [diaryPagi,diarySiang,diaryMalam])
        }
        
        diaryTable.delegate = self
        diaryTable.dataSource = self
        
    }
    
    func setDiary(arrayDiary: [Diary]){
        for diary in arrayDiary{
            dataDiary.append(diary)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchPage"{
            let vc = segue.destination as! SearchViewController
            vc.selectedSection = self.selectedSection
            vc.delegate = self
        }
    }
}


extension DiaryViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(dataDiary.count)
        return dataDiary.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + dataDiary[section].foods.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataDiary[indexPath.section]
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            
            cell.textLabel!.text = data.category.rawValue
            cell.detailTextLabel?.text = "\(data.sumCalories())"
            
            return cell
        }
        else if indexPath.row == (1 + dataDiary[indexPath.section].foods.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddFoodTableViewCell
            cell.section = data.category
            cell.delegate = self
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodListTableViewCell
            let food = dataDiary[indexPath.section].foods[indexPath.row-1]
            cell.lblFoodName.text = food.food.name
            cell.lblFoodCalorie.text = "\(food.food.calorie)"
            
            return cell
        }
    }
}

extension DiaryViewController: ButtonAddFood{
    func sendFoodData(food: UserFood) {
        
    }
    
    func buttonClicked(section: EatCategory) {
        self.selectedSection = section
        performSegue(withIdentifier: "toSearchPage", sender: self)
    }
}

extension DiaryViewController: SaveData{
    func dismissPage(dismiss: Bool) {
        
    }
    
    func saveData(food: Food, eatCategory: EatCategory, portion: Float, date: Date) {
        let newFoodInDiary = FoodInDiary(category: eatCategory, food: food, date: date, portion: portion)
        for (idx,diary) in dataDiary.enumerated(){
            if diary.category == newFoodInDiary.category{
                dataDiary[idx].foods.append(newFoodInDiary)
                self.diaryTable.reloadData()
                return
            }
        }
        
        let record = CKRecord(recordType: "Diary")
        
        record.setValue("CURRENT USER ID", forKey: "userID")
        record.setValue("CURRENT USER ACTIVITY", forKey: "activityID")
        record.setValue(food, forKey: "foodID")
        record.setValue(eatCategory, forKey: "category")
        record.setValue(date, forKey: "date")
        record.setValue(portion, forKey: "portion")
        
        database.save(record) { (record, error) in
            
            if error == nil {
                print("Record Saved. ID = \(record!.recordID.recordName)")
                
            }
            else{
                print("Record Not Saved")
            }
        }
    }
}
