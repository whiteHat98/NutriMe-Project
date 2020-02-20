//
//  RecomendationViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 22/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

class RecomendationViewController: UIViewController {

    
    @IBOutlet weak var recomendationTable: UITableView!
    
    var numberRow: Int = 0
    var macroCategory: String!
    var listForTable: [String] = []
    var listCarb : [String] = []
    var listProt : [String] = []
    var listFat : [String] = []
    
    var userInfo: UserInfo?
    var foodRecommendation:[Recommendation] = []
    
    let database = CKContainer.default().publicCloudDatabase
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard macroCategory != nil else {return}
        if macroCategory == "carb"{
            //isi list
            self.navigationItem.title = "Carbohydrates"
            listCarb.append("Rice")
            inputToListTable(list: listCarb)
            
        }else if macroCategory == "prot"{
            //isilist
            self.navigationItem.title = "Protein"
            listProt.append("Egg")
            inputToListTable(list: listProt)
            
        }else if macroCategory == "fat"{
            //isilist
            self.navigationItem.title = "Fat"
            listFat.append("Chicken")
            inputToListTable(list: listFat)
        }
        
        
        recomendationTable.delegate = self
        recomendationTable.dataSource = self
        recomendationTable.tableFooterView = UIView()
    }
    
    func inputToListTable(list: [String]){
        self.listForTable.removeAll()
        self.listForTable = list
        numberRow = listForTable.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getRecommendation()
    }
    
    func getRecommendation() {
        foodRecommendation.removeAll()
        
        let predicate = NSPredicate(format: "category == %@", self.macroCategory)
        
        let recommendationQuery = CKQuery(recordType: "Recommendation", predicate: predicate)
        
        database.perform(recommendationQuery, inZoneWith: nil) { (record, error) in
            if error == nil {
                for data in record! {
                    let category = data.value(forKey: "category") as! String
                    let name = data.value(forKey: "name") as! String
                    let desc = data.value(forKey: "desc") as! String
                    let restriction = data.value(forKey: "restrictions") as? String
                    
                    let recommendation = Recommendation(name: name, category: category, desc: desc, restriction: restriction)
                    
                    var restricted = false
                    if self.userInfo?.foodRestrictions != nil {
                        for restriction in self.userInfo!.foodRestrictions! {
                            if recommendation.restriction == restriction && restriction != nil{
                                restricted = true
                                break
                            }
                        }
                        
                        if restricted == false {
                            self.foodRecommendation.append(recommendation)
                        }
                    }
                }
                
                print(self.foodRecommendation)
                DispatchQueue.main.async {
                    self.recomendationTable.reloadData()
                }
            }
            else{
                print(error)
            }
        }
    }
}

extension RecomendationViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if foodRecommendation.count > 0 {
            return foodRecommendation.count
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRecomendation", for: indexPath)
        
        if foodRecommendation.count > 0 {
            cell.textLabel?.text = foodRecommendation[indexPath.row].name
            cell.detailTextLabel?.text = foodRecommendation[indexPath.row].desc
        }
        else{
            cell.textLabel?.text = "No Recommendation"
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.macroCategory == "fat" {
            UserDefaults.standard.set(foodRecommendation[indexPath.row].name, forKey: "fatRecommendation")
        }
        else if self.macroCategory == "protein" {
            UserDefaults.standard.set(foodRecommendation[indexPath.row].name, forKey: "proteinRecommendation")
        }
        else if self.macroCategory == "carb" {
            UserDefaults.standard.set(foodRecommendation[indexPath.row].name, forKey: "carbRecommendation")
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
