//
//  ViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 15/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    @IBOutlet weak var caloriesNeededLabel: UILabel!
    @IBOutlet weak var caloriesGoalLabel: UILabel!
    @IBOutlet weak var activityCaloriesLabel: UILabel!
    @IBOutlet weak var currentCaloriesLabel: UILabel!
    @IBOutlet weak var dashboardTableView: UITableView!
    @IBOutlet weak var btnActivityLevel: UIButton!
  
    let nutriens:[(String,String)]=[("Lemak","Daging"),("Protein","Telur"),("Karbohidrat","Jagung")]
    
    @IBAction func profilButton(_ sender: Any) {
        performSegue(withIdentifier: "toProfil", sender: self)
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
        self.tabBarController?.show(nextVC, sender: self)
        //self.show(nextVC, sender: self)
    }
    
    let database = CKContainer.default().publicCloudDatabase
    
    var userInfo : UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkUserInfo{
            let decoded = UserDefaults.standard.object(forKey: "userInfo") as! Data
            do{
                let decodedData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [], from: decoded) as! UserInfo
                print(decodedData)
            }catch{
                print(error)
            }
        }
      
      //self.btnActivityLevel.titleLabel?.text = "Activity Level (\(selectedActivities?.level.rawValue))"

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "toActivityPage"{
        let nextVC = segue.destination as! ActivityViewController
        nextVC.activityLevel = self.defaultActivityLevel
        nextVC.delegate = self
      }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //FETCH DATA
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
                
                self.userInfo = UserInfo(userID: userID, name: name, dob: stringToDate(dob), gender: gender, height: height , weight: weight , currCalories: 0, caloriesNeed: caloriesGoal!, activities: nil, foodRestriction: nil, reminder: nil, caloriesGoal: caloriesGoal!, carbohydrateGoal: carbohydrateGoal, fatGoal: fatGoal, proteinGoal: proteinGoal, mineralGoal: mineralGoal)
                
                print(self.userInfo?.name)
            }
            DispatchQueue.main.async {
              self.caloriesGoalLabel.text = "\(Int(self.userInfo!.caloriesGoal! * (self.selectedActivities?.caloriesMultiply ?? 1.2))) calories"
              self.activityCaloriesLabel.text = "\(Int((self.userInfo!.caloriesGoal! * (self.selectedActivities?.caloriesMultiply ?? 1.2)) - self.userInfo!.caloriesGoal!)) cal"
              self.currentCaloriesLabel.text = "ambil dari diary"
              
            }
            
        }

        self.setUpXib()
        self.dashboardTableView.delegate = self
        self.dashboardTableView.dataSource = self
        self.dashboardTableView.tableFooterView = UIView()
    }
    
    func checkUserInfo(completionHandler: @escaping()-> Void){
        if !UserDefaults.standard.bool(forKey: "userInfoExist"){
            let registerVC : RegisterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "registerVC") as! RegisterViewController
            
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Rekomendasi Makanan"
        case 1:
            return "Nutrisi Makro"
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
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellRekomendasi", for: indexPath) as? rekomendasiTableViewCell
            print(nutriens[indexPath.row])
            cell?.lblNamaMakanan.text = nutriens[indexPath.row].1
            cell?.lblNamaMakro.text = nutriens[indexPath.row].0
            return cell!
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMakro", for: indexPath) as? giziTableViewCell
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMineral", for: indexPath) as? mineralTableViewCell
        return cell!
    }
}

extension ViewController : UpdateData{
  func updateActivity(activity: Activity) {
    self.selectedActivities = activity
    self.defaultActivityLevel = activity.id
    DispatchQueue.main.async {
      if activity.id == 1{
        self.btnActivityLevel.titleLabel?.text = "Activity Level-Med"

      }else{
        self.btnActivityLevel.titleLabel?.numberOfLines = 0
        //self.btnActivityLevel.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnActivityLevel.titleLabel?.text = "Activity Level-\(activity.level.rawValue)"
      }
    }
      
  }
  
}

