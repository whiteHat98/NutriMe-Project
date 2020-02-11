//
//  ViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 15/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import CloudKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var caloriesNeededLabel: UILabel!
    @IBOutlet weak var caloriesGoalLabel: UILabel!
    @IBOutlet weak var activityCaloriesLabel: UILabel!
    @IBOutlet weak var currentCaloriesLabel: UILabel!
    @IBOutlet weak var dashboardTableView: UITableView!
    @IBOutlet weak var btnActivityLevel: UIButton!
    @IBOutlet weak var caloriesTitleLabel: UILabel!
    @IBOutlet weak var buttonProfile: UIButton!
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    let healthKitStore = HKHealthStore()
    
    //let nutriens:[(String,String)]=[("Karbohidrat","Jagung"),("Protein","Telur"),("Lemak","Daging")]
    let nutriens:[String]=["Carbohydrate","Fat","Protein"]
    //
    //    var totalCalories : Double = 0
    //    var totalCarbohidrates : Double = 0
    //    var totalProtein : Double = 0
    //    var totalFat : Double = 0
    //    var diaryID : [String] = []
    let db = DatabaseNutriMe()
    
    var totalCalories : Double = 0
    var totalCarbohidrates : Double = 0
    var totalProtein : Double = 0
    var totalFat : Double = 0
    var totalCaloriesGoal : Double = 0
    var diaryID : [String] = []
    
    var totalActiveEnergy:Double = 0
    var totalStepCount:Double = 0
    
    @IBAction func profilButton(_ sender: Any) {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    //activity level in diary (0-2) gak blh lebih / kurang
    var defaultActivityLevel = 0
    var selectedActivities : Activity?
    @IBAction func setActivityButton(_ sender: Any) {
        performSegue(withIdentifier: "toActivityPage", sender: self)
    }
    
    @IBAction func addFoodButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Diary", bundle: nil)
        let nextVC = storyboard.instantiateViewController(identifier: "SearchView") as! SearchViewController
       // nextVC.selectedSection = .pagi
        self.tabBarController?.show(nextVC, sender: self)
        //self.show(nextVC, sender: self)
    }
    
    let database = CKContainer.default().publicCloudDatabase
    
    var userInfo : UserInfo?
    
    var selectedMacro: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkUserInfo {
            let decoded = UserDefaults.standard.object(forKey: "userInfo") as! Data
            do{
                let decodedData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [], from: decoded) as! UserInfo
                print(decodedData)
            }catch{
                print(error)
            }
            
        }
        
        self.setUpXib()
        self.dashboardTableView.delegate = self
        self.dashboardTableView.dataSource = self
        self.dashboardTableView.tableFooterView = UIView()
        
//        self.btnActivityLevel.titleLabel?.text = "Activity Level (\(selectedActivities?.level.rawValue))"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toActivityPage"{
            let nextVC = segue.destination as! ActivityViewController
            nextVC.activityLevel = self.defaultActivityLevel
            nextVC.delegate = self
        }
        else if segue.identifier == "toProfile"{
            let nextVC = segue.destination as! ProfilViewController
            nextVC.userInfo = self.userInfo
        }
        else if segue.identifier == "toRecomendation" {
            let nextVC = segue.destination as! RecomendationViewController
            nextVC.macroCategory = self.selectedMacro
            nextVC.userInfo = self.userInfo
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkUserInfo {}
        self.buttonProfile.isEnabled = false
        
        if let activityId = UserDefaults.standard.value(forKey: "userActivityLevel") as? Int{
            switch activityId {
            case 0:
                selectedActivities = Activity(id: 0, level: .low, desc: "driving, berjalan, office work, reading", caloriesMultiply: 1.2)
            case 1:
                selectedActivities = Activity(id: 1, level: .medium, desc: "gardening, biking, fast walking", caloriesMultiply: 1.55)
            case 2:
                selectedActivities = Activity(id: 2, level: .high, desc: "aerobics, badminton, jogging", caloriesMultiply: 1.725)
            case 3:
                selectedActivities = Activity(id: 3, level: .live, desc: "Connected with Health App, based on your dairy activity", caloriesMultiply: 1)
            default:
                selectedActivities = Activity(id: 0, level: .low, desc: "driving, berjalan, office work, reading", caloriesMultiply: 1.2)
            }
        }else{
            selectedActivities = Activity(id: 0, level: .low, desc: "driving, berjalan, office work, reading", caloriesMultiply: 1.2)
        }


        guard let userID = UserDefaults.standard.value(forKey: "currentUserID") as? String else {return}
        db.fetchDataUser(userID: userID, completion: { (userInfo) in
            DispatchQueue.main.async {
                self.userInfo = userInfo
                self.db.userInfo = userInfo

                self.caloriesGoalLabel.text = "\(10 * Double(userInfo.caloriesGoal! * ((self.selectedActivities?.caloriesMultiply)!)).rounded() / 10) calories"


                self.dashboardTableView.reloadData()
                self.buttonProfile.isEnabled = true

                self.db.getUserData(completion: {
//
//                    if err != nil{
//                        if !CheckInternet.Connection(){
//                            let alert = UIAlertController(title: "Internet Connection", message: "Internet connection required please check your internet connection!", preferredStyle: .alert)
//                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                    }else{
                        DispatchQueue.main.async {
                            
                            var caloriesNeeded = (10 * (Double(userInfo.caloriesGoal! * (self.selectedActivities!.caloriesMultiply!)) - self.db.totalCalories)).rounded() / 10
                            
                            if caloriesNeeded < 0 {
                                self.caloriesTitleLabel.text = "Over"
                                self.caloriesNeededLabel.textColor = .systemRed
                                caloriesNeeded = caloriesNeeded * -1
                            }
                            else{
                                self.caloriesTitleLabel.text = "Remaining"
                                self.caloriesNeededLabel.textColor = .label
                            }
                            
                            self.caloriesNeededLabel.text = "\(caloriesNeeded)"

                            self.dashboardTableView.reloadData()
                            self.currentCaloriesLabel.text = "\(Int(self.db.totalCalories)) cal"
                            print(self.db.totalCalories)
                            if !UserDefaults.standard.bool(forKey: "isReportCreated"){
                                self.db.createReportRecord()
                            }else{
                                if UserDefaults.standard.bool(forKey: "needUpdate"){
                                    self.db.updateReport()
                                    UserDefaults.standard.set(false, forKey: "needUpdate")
                                }
                            }
                            
                        }
                        
                            if UserDefaults.standard.value(forKey: "userActivityLevel") != nil {
                                self.defaultActivityLevel = UserDefaults.standard.value(forKey: "userActivityLevel") as! Int
                            }

                            if self.defaultActivityLevel != 3 {
                                DispatchQueue.main.async{
                                    self.activityCaloriesLabel.text = "\(10 * Double((userInfo.caloriesGoal! * (self.selectedActivities?.caloriesMultiply ?? 1.2)) - userInfo.caloriesGoal!).rounded() / 10) cal"
                                    if let title = UserDefaults.standard.value(forKey: "activityLabel") as? String{
                                        self.btnActivityLevel.titleLabel?.text = title
                                    }
                                }
                            }
                            else{
                                self.getTodaysSteps { (step) in
                                    self.totalStepCount = step
                                    self.getTodaysActiveEnergy { (energy) in
                                        self.totalActiveEnergy = energy
                                        let totalEnergy = (self.totalStepCount * 0.04) + self.totalActiveEnergy
                                        DispatchQueue.main.async {
                                            self.activityCaloriesLabel.text = "\(10 * Double(totalEnergy).rounded() / 10)"
//                                            self.btnActivityLevel.titleLabel?.text = "Activity Level-Live"
                                            if let title = UserDefaults.standard.value(forKey: "activityLabel") as? String{
                                                self.btnActivityLevel.titleLabel?.text = title
                                            }
                                        }
                                    }
                                }
                            }

                })
            }
        })
    }
    
    func checkUserInfo(completionHandler: @escaping()-> Void){
        if !UserDefaults.standard.bool(forKey: "userInfoExist"){
            
            let registerVB : UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginVc") as! UINavigationController
            let registerVC = registerVB.viewControllers[0] as! LoginViewController
            
            if let navBar = self.navigationController{
                //navBar.present(registerVC, animated: true, completion: nil)
                navBar.pushViewController(registerVC, animated: false)
            }else{
                _ = UINavigationController(rootViewController: registerVC)
                self.present(registerVC, animated: true, completion: nil)
            }
        }
    }
    
    func setUpXib(){
        dashboardTableView.register(UINib(nibName: "rekomendasiTableViewCell", bundle: nil), forCellReuseIdentifier: "cellRekomendasi")
        dashboardTableView.register(UINib(nibName: "giziTableViewCell", bundle: nil), forCellReuseIdentifier: "cellMakro")
        dashboardTableView.register(UINib(nibName: "mineralTableViewCell", bundle: nil), forCellReuseIdentifier: "cellMineral")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
                selectedMacro = "carb"
            }else if indexPath.row == 1{
                selectedMacro = "fat"
            }else if indexPath.row == 2{
                selectedMacro = "protein"
            }
            performSegue(withIdentifier: "toRecomendation", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Food Recommendation"
        case 1:
            return "Macronutriens"
        case 2:
            return "Mineral"
        default:
            break
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return nutriens.count
        case 1:
            return 1
        case 2:
            return 1
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return 200
        } else if indexPath.section == 2{
            return 65
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellRekomendasi", for: indexPath) as? rekomendasiTableViewCell
            //print(nutriens[indexPath.row])
            
            cell?.lblNamaMakro.text = nutriens[indexPath.row]
            
            if indexPath.row == 0 {
                if UserDefaults.standard.value(forKey: "carbRecommendation") != nil {
                    cell?.lblNamaMakanan.text = UserDefaults.standard.value(forKey: "carbRecommendation") as! String
                }
                else{
                    cell?.lblNamaMakanan.text = "Click to Choose"
                }
            }
            else if indexPath.row == 1 {
                if UserDefaults.standard.value(forKey: "fatRecommendation") != nil {
                    cell?.lblNamaMakanan.text = UserDefaults.standard.value(forKey: "fatRecommendation") as! String
                }
                else{
                    cell?.lblNamaMakanan.text = "Click to Choose"
                }
            }
            else if indexPath.row == 2 {
                if UserDefaults.standard.value(forKey: "proteinRecommendation") != nil {
                    cell?.lblNamaMakanan.text = UserDefaults.standard.value(forKey: "proteinRecommendation") as! String
                }
                else{
                    cell?.lblNamaMakanan.text = "Click to Choose"
                }
            }
            cell?.selectionStyle = .none
            return cell!
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMakro", for: indexPath) as? giziTableViewCell
            
            let progressKarbo: Float = Float(self.db.totalCarbohidrates) / (self.userInfo?.carbohydrateGoal ?? 0)
            let progressProtein: Float = Float(self.db.totalProtein) / (self.userInfo?.proteinGoal ?? 0)
            let progressLemak: Float = Float(self.db.totalFat) / (self.userInfo?.fatGoal ?? 0)
            
            //            print(progressKarbo)
            //            print(progressProtein)
            //            print(progressLemak)
            
            cell?.pvKarbo.setProgress(progressKarbo, animated: true)
            cell?.pvProtein.setProgress(progressProtein, animated: true)
            cell?.pvLemak.setProgress(progressLemak, animated: true)
            
            cell?.fatLabel.text = "\((10 * self.db.totalFat).rounded() / 10) / \((10 * (self.userInfo?.fatGoal ?? 0) ).rounded() / 10)"
            cell?.proteinLabel.text = "\((10 * self.db.totalProtein).rounded() / 10) / \((10 * (self.userInfo?.proteinGoal ?? 0) ).rounded() / 10)"
            cell?.carboLabel.text = "\((10 * self.db.totalCarbohidrates).rounded() / 10) / \((10 * (self.userInfo?.carbohydrateGoal ?? 0) ).rounded() / 10)"
            
            cell?.delegate = self
            cell?.selectionStyle = .none
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMineral", for: indexPath) as? mineralTableViewCell
        cell?.selectionStyle = .none
        return cell!
    }
}

extension ViewController : UpdateData{
    func updateActivity(activity: Activity) {
        self.selectedActivities = activity
        self.defaultActivityLevel = activity.id
        UserDefaults.standard.set(activity.id, forKey: "userActivityLevel")
        
        DispatchQueue.main.async {
            if activity.id == 1{
                self.btnActivityLevel.titleLabel?.text = "Activity Level-Med"
            }else if activity.id == 3{
                self.btnActivityLevel.titleLabel?.text = "Activity Level-Live"
            }else{
                self.btnActivityLevel.titleLabel?.numberOfLines = 0
                //self.btnActivityLevel.titleLabel?.adjustsFontSizeToFitWidth = true
                self.btnActivityLevel.titleLabel?.text = "Activity Level-\(activity.level.rawValue)"
            }
            UserDefaults.standard.set(self.btnActivityLevel.titleLabel?.text, forKey: "activityLabel")
        }
    }
    
    func updateRecommendation() {
        
    }
}

extension ViewController : DetailAction{
    func detailActionClicked() {
        let storyboard = UIStoryboard(name: "Report", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "third")
        self.present(vc, animated: true, completion: nil)
        print("Masuk gak?")
    }
}

extension ViewController{
    
    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        healthKitStore.execute(query)
    }
    
    func getTodaysActiveEnergy(completion: @escaping (Double) -> Void) {
        let energyQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: energyQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, _) in
            guard let result = result, let sum = result.sumQuantity() else{
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.kilocalorie()))
        }
        
        healthKitStore.execute(query)
    }
}

