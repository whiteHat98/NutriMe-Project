//
//  DiaryViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 18/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import CloudKit




class DiaryViewController: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var CalendarCollectionView: UICollectionView!
    
    var foodList:[(food: String, calorie: Float)]=[("Nasi", 10),("Apple",12),("Nanas", 6),("Salmon",20)]
    var foodEaten:[FoodInDiary] = []
    var category:[EatCategory] = [.pagi, .siang, .malam]
    var dataDiary:[Diary] = []
    var selectedSection: EatCategory?
    var refreshControl = UIRefreshControl()
    
    var userDiary: Diary?
    var diaryPagi: [Diary] = []
    var diarySiang: [Diary] = []
    var diaryMalam: [Diary] = []
    var selectedDiary: Diary?
    var totalKaloriPagi: Float = 0
    var totalKaloriSiang: Float = 0
    var totalKaloriMalam: Float = 0
    
    var monthForQuery = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var selectedDay:Int = Int()
    var selectedMonth:String = String()
    var selectedMonthNumber = Int()
    var selectedYear:Int = Int()
    var selectedIndexPath: IndexPath? = nil
    var selectedIndex = 0
    var titleText = ""
    var startWithCurrentDate = false
    
    var formatter = DateFormatter()
    
    let database = CKContainer.default().publicCloudDatabase
    var userID:String = ""
    
    @IBOutlet weak var lblKetHari: UILabel!
    @IBOutlet weak var diaryTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        diaryTable.addSubview(refreshControl)
        
        if let id = UserDefaults.standard.value(forKey: "currentUserID") as? String{
            userID = id
        }
        
        for (food,calorie) in foodList{
            let eat = FoodInDiary(category: .pagi, food: Food(name: food, calorie: calorie), date: Date(), portion: 1)
            foodEaten.append(eat)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        selectedDay = calendarDay
        selectedMonth = "\(months[calendarMonth])"
        selectedMonthNumber = calendarMonth
        selectedYear = calendarYear
        selectedIndexPath = nil
        
        selectedDateLabel.text = "\(selectedDay) \(selectedMonth) \(selectedYear)"
        monthLabel.text = "\(selectedMonth) \(calendarYear)"
        scrollTo(item: selectedDay, section: 0)
        CalendarCollectionView.reloadData()
        
        queryUserFood()
        diaryTable.tableFooterView = UIView()
        diaryTable.delegate = self
        diaryTable.dataSource = self
    }
    
    func scrollTo(item: Int, section: Int) {
        let scrollTo = IndexPath(item: item, section: section)
        self.CalendarCollectionView.scrollToItem(at: scrollTo, at: .centeredHorizontally, animated: true)
        
    }
    
    func goToNextMonth() {
        switch selectedMonth {
        case "December":
            calendarMonth = 0
            calendarYear += 1
            
            if leapYearCounter < 5 {
                leapYearCounter += 1
            }
            
            if leapYearCounter == 4 {
                daysInMonth[1] = 29
            }
            if leapYearCounter == 5{
                leapYearCounter = 1
                daysInMonth[1] = 28
            }
        default:
            calendarMonth += 1
        }
    }
    
    func goToPreviousMonth() {
        switch selectedMonth {
        case "January":
            calendarMonth = 11
            calendarYear -= 1
            
            if leapYearCounter > 0 {
                leapYearCounter -= 1
            }
            
            if leapYearCounter == 0 {
                daysInMonth[1] = 29
                leapYearCounter = 4
            }
            else{
                daysInMonth[1] = 29
            }
        default:
            calendarMonth -= 1
        }
    }
    
    func queryUserFood() {
        var getSelectedDate = ""
        if let weekDay = getDayOfWeek("\(selectedDay)-\(selectedMonth)-\(selectedYear)") {
            getSelectedDate = "\(weekDays[weekDay-1]), \(selectedDay) \(monthForQuery[calendarMonth]) \(selectedYear)"
        }
        
        //        formatter.dateFormat = "EEEE, d MMM yyyy"
        let selectedDate: String = "\(getSelectedDate)"
        print(selectedDate)
        
        let predicate1 = NSPredicate(format: "userID == %@", userID)
        let predicate2 = NSPredicate(format: "date == %@", selectedDate)
        let predicates = [predicate1, predicate2]
        
        let diaryQuery = CKQuery(recordType: "Diary", predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        
        //        let diaryQuery = CKQuery(recordType: "Diary", predicate: NSPredicate(format: "userID == %@", userID))
        
        database.perform(diaryQuery, inZoneWith: nil) { (record, error) in
            if error == nil {
                self.diaryPagi.removeAll()
                self.diarySiang.removeAll()
                self.diaryMalam.removeAll()
                self.totalKaloriPagi = 0
                self.totalKaloriSiang = 0
                self.totalKaloriMalam = 0
                //                self.totalKaloriHarian = 0
                //                self.totalKarboHarian = 0
                //                self.totalLemakHarian = 0
                //                self.totalProteinHarian = 0
                
                for data in record! {
                    
                    let id = data.recordID
                    let category = data.value(forKey: "category") as! String
                    let date = data.value(forKey: "date") as! String
                    let foodCalories = data.value(forKey: "foodCalories") as! Float
                    let foodCarbohydrate = data.value(forKey: "foodCarbohydrate") as! Float
                    let foodProtein = data.value(forKey: "foodProtein") as! Float
                    let foodFat = data.value(forKey: "foodFat") as! Float
                    let foodName = data.value(forKey: "foodName") as! String
                    let portion = data.value(forKey: "portion") as! Float
                    
                    
                    self.userDiary = Diary(id: id, category: category, date: date, foodName: foodName, foodCalories: foodCalories, foodCarbohydrate: foodCarbohydrate, foodFat: foodFat, foodProtein: foodProtein, portion: portion)
                    
                    print(category)
                    
                    if category == "Breakfast" {
                        self.diaryPagi.append(self.userDiary!)
                        self.totalKaloriPagi += self.userDiary!.foodCalories
                    }
                    else if category == "Lunch" {
                        self.diarySiang.append(self.userDiary!)
                        self.totalKaloriSiang += self.userDiary!.foodCalories
                    }
                    else {
                        self.diaryMalam.append(self.userDiary!)
                        self.totalKaloriMalam += self.userDiary!.foodCalories
                    }
                    self.dataDiary.append(self.userDiary!)
                    
                    //                    self.totalKarboHarian += self.userDiary!.foodCarbohydrate
                    //                    self.totalLemakHarian += self.userDiary!.foodFat
                    //                    self.totalProteinHarian += self.userDiary!.foodProtein
                }
                
                //                self.totalKaloriHarian = self.totalKaloriPagi + self.totalKaloriSiang + self.totalKaloriMalam
                //
                //                UserDefaults.standard.set(self.totalKaloriHarian, forKey: "kaloriHarian")
                //                UserDefaults.standard.set(self.totalKarboHarian, forKey: "karboHarian")
                //                UserDefaults.standard.set(self.totalLemakHarian, forKey: "lemakHarian")
                //                UserDefaults.standard.set(self.totalProteinHarian, forKey: "proteinHarian")
                //
                //

                
                DispatchQueue.main.async {
                    self.diaryTable.reloadData()
                    self.refreshControl.endRefreshing()
                }
                
            }
        }
        
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
        else if segue.identifier == "segueToDetailFood" {
            let vc = segue.destination as! detailFoodViewController
            vc.diaryDetail = self.selectedDiary
        }
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        goToNextMonth()
        
        selectedMonth = months[calendarMonth]
        monthLabel.text = "\(selectedMonth) \(calendarYear)"
        selectedIndexPath = nil
        scrollTo(item: selectedDay-1, section: 0)
        selectedDateLabel.text = "\(selectedDay) \(selectedMonth) \(calendarYear)"
        selectedIndexPath = [0, selectedDay - 1]
        CalendarCollectionView.reloadData()
        queryUserFood()
    }
    
    @IBAction func prevButtonClick(_ sender: Any) {
        goToPreviousMonth()
        
        selectedMonth = months[calendarMonth]
        monthLabel.text = "\(selectedMonth) \(calendarYear)"
        selectedIndexPath = nil
        scrollTo(item: selectedDay-1, section: 0)
        selectedDateLabel.text = "\(selectedDay) \(selectedMonth) \(calendarYear)"
        selectedIndexPath = [0, selectedDay - 1]
        CalendarCollectionView.reloadData()
        queryUserFood()
        
    }
    
    @objc func refresh(sender:AnyObject) {
       queryUserFood()
    }
    
}


extension DiaryViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //        print(dataDiary.count)
        //        return dataDiary.count
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return 2 + dataDiary[section].foods.count
        switch section {
        case 0:
            if diaryPagi.count != 0 {
                return 2 + diaryPagi.count
            }
            else{
                return 3
            }
        case 1:
            if diarySiang.count != 0 {
                return 2 + diarySiang.count
            }
            else{
                return 3
            }
        case 2:
            if diaryMalam.count != 0 {
                return 2 + diaryMalam.count
            }
            else{
                return 3
            }
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(indexPath.section)
        if indexPath.row != 0 && indexPath.row != tableView.numberOfRows(inSection: indexPath.section) {
            if indexPath.section == 0 && diaryPagi.count != 0{
                selectedDiary = diaryPagi[indexPath.row - 1]
                performSegue(withIdentifier: "segueToDetailFood", sender: self)
            }
            else if indexPath.section == 1 && diarySiang.count != 0{
                selectedDiary = diarySiang[indexPath.row - 1]
                performSegue(withIdentifier: "segueToDetailFood", sender: self)
            }
            else if indexPath.section == 2 && diaryMalam.count != 0{
                selectedDiary = diaryMalam[indexPath.row - 1]
                performSegue(withIdentifier: "segueToDetailFood", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
                cell.textLabel?.text = "Breakfast"
                cell.detailTextLabel?.text = "\(totalKaloriPagi) Cal"
                return cell
            }
            else if indexPath.row != tableView.numberOfRows(inSection: 0) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodListTableViewCell
                
                if diaryPagi.count != 0 {
                    cell.lblFoodName.text = diaryPagi[indexPath.row - 1].foodName
                    cell.lblFoodCalorie.text = "\(diaryPagi[indexPath.row - 1].foodCalories)"
                    cell.accessoryType = .disclosureIndicator
                    cell.selectionStyle = .default
                }
                else{
                    cell.lblFoodName.text = "No Food Inserted"
                    cell.lblFoodCalorie.text = ""
                    cell.accessoryType = .none
                    cell.selectionStyle = .none
                }
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddFoodTableViewCell
                cell.section = EatCategory.pagi
                cell.delegate = self
                
                return cell
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
                cell.textLabel?.text = "Lunch"
                cell.detailTextLabel?.text = "\(totalKaloriSiang) Cal"
                return cell
            }
            else if indexPath.row != tableView.numberOfRows(inSection: 1) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodListTableViewCell
                
                if diarySiang.count != 0 {
                    cell.lblFoodName.text = diarySiang[indexPath.row - 1].foodName
                    cell.lblFoodCalorie.text = "\(diarySiang[indexPath.row - 1].foodCalories)"
                    cell.accessoryType = .disclosureIndicator
                    cell.selectionStyle = .default
                }
                else{
                    cell.lblFoodName.text = "No Food Inserted"
                    cell.lblFoodCalorie.text = ""
                    cell.accessoryType = .none
                    cell.selectionStyle = .none
                }
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddFoodTableViewCell
                cell.section = EatCategory.siang
                cell.delegate = self
                return cell
            }
        }
        else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
                cell.textLabel?.text = "Dinner"
                cell.detailTextLabel?.text = "\(totalKaloriMalam) Cal"
                return cell
            }
            else if indexPath.row != tableView.numberOfRows(inSection: 2) - 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodListTableViewCell
                
                if diaryMalam.count != 0 {
                    cell.lblFoodName.text = diaryMalam[indexPath.row - 1].foodName
                    cell.lblFoodCalorie.text = "\(diaryMalam[indexPath.row - 1].foodCalories)"
                    cell.accessoryType = .disclosureIndicator
                    cell.selectionStyle = .default
                }
                else{
                    cell.lblFoodName.text = "No Food Inserted"
                    cell.lblFoodCalorie.text = ""
                    cell.accessoryType = .none
                    cell.selectionStyle = .none
                }
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddFoodTableViewCell
                cell.section = EatCategory.malam
                cell.delegate = self
                return cell
            }
        }
        //        let data = dataDiary[indexPath.section]
        //        if indexPath.row == 0{
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        //
        //            cell.textLabel!.text = data.category.rawValue
        //            cell.detailTextLabel?.text = "\(data.sumCalories())"
        //
        //            return cell
        //        }
        //        else if indexPath.row == (1 + dataDiary[indexPath.section].foods.count){
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddFoodTableViewCell
        //            cell.section = data.category
        //            cell.delegate = self
        //
        //            return cell
        //        }
        //        else{
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodListTableViewCell
        //            let food = dataDiary[indexPath.section].foods[indexPath.row-1]
        //            cell.lblFoodName.text = food.food.name
        //            cell.lblFoodCalorie.text = "\(food.food.calorie)"
        //
        //            return cell
        //        }
    }
}

extension DiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth[selectedMonthNumber]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        cell.circle.isHidden = true
        cell.dateLabel.text = "\(indexPath.row + 1)"
        
        if selectedIndexPath == indexPath {
            cell.isSelected = true
            cell.dateLabel.textColor = UIColor.white
            cell.circle.isHidden = false
            cell.DrawCircle()
        }
        else{
            cell.isSelected = false
            cell.dateLabel.textColor = UIColor.label
            cell.circle.isHidden = true
            
        }
        
        if selectedMonth == months[calendar.component(.month, from: date) - 1] && calendarYear == calendar.component(.year, from: date) && indexPath.row + 1 == calendarDay{
            cell.dateLabel.textColor = UIColor.white
            cell.circle.isHidden = false
            cell.DrawGreyCircle()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !startWithCurrentDate {
            scrollTo(item: selectedDay-1, section: 0)
            startWithCurrentDate = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath != nil {
            if indexPath.compare(selectedIndexPath!) == ComparisonResult.orderedSame {
                selectedIndexPath = nil
            }
            else{
                selectedIndexPath = indexPath
            }
        }
        else{
            selectedIndexPath = indexPath
        }
        
        selectedDay = indexPath.row + 1
        selectedMonth = months[calendarMonth]
        selectedYear = calendarYear
        
        CalendarCollectionView.reloadItems(at: CalendarCollectionView.indexPathsForVisibleItems)
        selectedDateLabel.text = "\(selectedDay) \(selectedMonth) \(selectedYear)"
        scrollTo(item: indexPath.row, section: 0)
        queryUserFood()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !startWithCurrentDate {
            scrollTo(item: selectedDay-1, section: 0)
            startWithCurrentDate = true
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
    func saveData(food: Food, eatCategory: EatCategory, portion: Float, date: Date) {
        
    }
    
    func dismissPage(dismiss: Bool) {
        if dismiss{
            self.diaryTable.reloadData()
            print("WORKKRKRKRK")
        }
    }
    
    
}

//extension DiaryViewController: SaveData{
//    func dismissPage(dismiss: Bool) {
//
//    }
//
//    func saveData(food: Food, eatCategory: EatCategory, portion: Float, date: Date) {
//        let newFoodInDiary = FoodInDiary(category: eatCategory, food: food, date: date, portion: portion)
//        for (idx,diary) in dataDiary.enumerated(){
//            if diary.category == newFoodInDiary.category{
//                dataDiary[idx].foods.append(newFoodInDiary)
//                self.diaryTable.reloadData()
//                return
//            }
//        }

//        let record = CKRecord(recordType: "Diary")
//
//        record.setValue("CURRENT USER ID", forKey: "userID")
//        record.setValue("CURRENT USER ACTIVITY", forKey: "activityID")
//        record.setValue(food, forKey: "foodID")
//        record.setValue(eatCategory, forKey: "category")
//        record.setValue(date, forKey: "date")
//        record.setValue(portion, forKey: "portion")
//
//        database.save(record) { (record, error) in
//
//            if error == nil {
//                print("Record Saved. ID = \(record!.recordID.recordName)")
//
//            }
//            else{
//                print("Record Not Saved")
//            }
//        }
//    }
//}
