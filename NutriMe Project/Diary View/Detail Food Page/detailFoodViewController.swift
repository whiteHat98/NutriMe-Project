//
//  detailFoodViewController.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 10/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

class detailFoodViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let database = CKContainer.default().publicCloudDatabase
    var diaryDetail: Diary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    @IBAction func deleteButtonClick(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Diary", message: "Are you sure want do delete this diary?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            print("deleting Diary...")
            self.deleteDiary()
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteDiary() {
        let recordID: CKRecord.ID = diaryDetail!.id
        
        database.delete(withRecordID: recordID) { (deletedRecordID, error) in
            if error == nil {
                print("Record Deleted")
            }
            else{
                print("Record Not Deleted")
            }
        }
    }
}

extension detailFoodViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Nutrisi"
        }
        else{
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailFoodCell", for: indexPath) as! detailFoodTableViewCell
        
        if diaryDetail != nil {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell.titleText.text = "\(diaryDetail!.date)"
                    cell.valueText.text = ""
                }
                else if indexPath.row == 1 {
                    cell.titleText.text = "\(diaryDetail!.category)"
                    cell.valueText.text = ""
                }
                else if indexPath.row == 2 {
                    cell.titleText.text = "\(diaryDetail!.foodName)"
                    cell.valueText.text = "\(diaryDetail!.foodCalories) Kkal"
                }
                else if indexPath.row == 3 {
                    cell.titleText.text = "Portion"
                    cell.valueText.text = "\(diaryDetail!.portion)"
                }
            }
            else{
                if indexPath.row == 0 {
                    cell.titleText.text = "Fat"
                    cell.valueText.text = "\(diaryDetail!.foodFat)"
                }
                if indexPath.row == 1 {
                    cell.titleText.text = "Protein"
                    cell.valueText.text = "\(diaryDetail!.foodProtein)"
                }
                if indexPath.row == 2 {
                    cell.titleText.text = "Carbohydrates"
                    cell.valueText.text = "\(diaryDetail!.foodCarbohydrate)"
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
}
