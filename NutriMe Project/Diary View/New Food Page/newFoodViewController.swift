//
//  newFoodViewController.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 07/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

class newFoodViewController: UIViewController {

    @IBOutlet weak var newFoodTableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var namaMakanan = String()
    var porsiMakanan = String()
    var kaloriMakanan = String()
    var lemakMakanan = String()
    var proteinMakanan = String()
    var karbohidratMakanan = String()
    
    let database = CKContainer.default().publicCloudDatabase
    let userID:String = UserDefaults.standard.value(forKey: "currentUserID") as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newFoodTableView.delegate = self
        newFoodTableView.dataSource = self
        newFoodTableView.tableFooterView = UIView()
        
        enableSaveButton()
    }
    
    
    func enableSaveButton() {
        if namaMakanan == "" || porsiMakanan == "" || kaloriMakanan == "" || lemakMakanan == "" || proteinMakanan == "" || karbohidratMakanan == "" {
            saveButton.isEnabled = false
        }
        else{
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
        
        let foodRecord = CKRecord(recordType: "Food")
        
        foodRecord.setValue(self.namaMakanan, forKey: "name")
        foodRecord.setValue(self.kaloriMakanan.floatValue, forKey: "calories")
        foodRecord.setValue(self.userID, forKey: "userID")
        //Restriction belum masuk
        
        self.database.save(foodRecord) { (record, error) in
            if error == nil {
                print(record!.recordID.recordName)
                
                let makroRecord = CKRecord(recordType: "Makros")
                
                makroRecord.setValue(record?.recordID.recordName, forKey: "foodID")
                makroRecord.setValue(self.lemakMakanan.floatValue, forKey: "fat")
                makroRecord.setValue(self.proteinMakanan.floatValue, forKey: "protein")
                makroRecord.setValue(self.karbohidratMakanan.floatValue, forKey: "carbohydrate")
                
                self.database.save(makroRecord) { (record, error) in
                    if error == nil {
                        print(record!.recordID.recordName)
                        
                        DispatchQueue.main.async {
                            self.navigationController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            else{
                print("error saving new food")
            }
        }
        
//        let makroRecord = CKRecord(recordType: "Makros")
//
//        makroRecord.setValue(lemakMakanan.floatValue, forKey: "fat")
//        makroRecord.setValue(proteinMakanan.floatValue, forKey: "protein")
//        makroRecord.setValue(karbohidratMakanan.floatValue, forKey: "carbohydrate")
//
//        database.save(makroRecord) { (record, error) in
//            if error == nil {
//                print(record!.recordID.recordName)
//
//                let foodRecord = CKRecord(recordType: "Food")
//
//                foodRecord.setValue(self.namaMakanan, forKey: "name")
//                foodRecord.setValue(record!.recordID.recordName, forKey: "makrosID")
//                foodRecord.setValue(self.kaloriMakanan.floatValue, forKey: "calories")
//                foodRecord.setValue(self.userID, forKey: "userID")
//                //Restriction belum masuk
//
//                self.database.save(foodRecord) { (record, error) in
//                    if error == nil {
//                        print(record!.recordID.recordName)
//
//                        DispatchQueue.main.async {
//                            self.navigationController?.dismiss(animated: true, completion: nil)
//                        }
//                    }
//                }
//            }
//            else{
//                print("error saving new food")
//                print(error)
//            }
//
//        }
    }
    
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension newFoodViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Food Data"
        case 1:
            return "Nutrition"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newFoodCell", for: indexPath) as! newFoodTableViewCell
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.labelText.text = "Food Name"
                cell.textField.placeholder = "Apel"
            }
            else if indexPath.row == 1 {
                cell.labelText.text = "Portion per Serving"
                cell.textField.placeholder = "100 g"
            }
            else if indexPath.row == 2 {
                cell.labelText.text = "Total Calories"
                cell.textField.placeholder = "200 g"
            }
            cell.textField.tag = indexPath.row
            print(cell.textField.tag)
            
        case 1:
            if indexPath.row == 0 {
                cell.labelText.text = "Total Fat"
                cell.textField.placeholder = "15 g"
            }
            else if indexPath.row == 1 {
                cell.labelText.text = "Total Protein"
                cell.textField.placeholder = "10 g"
            }
            else if indexPath.row == 2 {
                cell.labelText.text = "Total Carbohydrates"
                cell.textField.placeholder = "5 g"
            }
            cell.textField.tag = indexPath.row + 3
            
        default:
            return cell
        }
        
        if indexPath.section == 0 {
            if indexPath.row != 0 {
                cell.textField.keyboardType = UIKeyboardType.numberPad
            }
        }
        else{
            cell.textField.keyboardType = UIKeyboardType.numberPad
        }
        
        return cell
    }
    
}

extension newFoodViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let textFieldRow = textField.tag
        
        if textFieldRow == 0 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Nama harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            namaMakanan = textField.text!
        }
        else if textFieldRow == 1 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Porsi harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            porsiMakanan = textField.text!
        }
        else if textFieldRow == 2 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Kalori harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            kaloriMakanan = textField.text!
        }
        else if textFieldRow == 3 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Lemak harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            lemakMakanan = textField.text!
        }
        else if textFieldRow == 4 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Protein harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            proteinMakanan = textField.text!
        }
        else if textFieldRow == 5 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Karbohidrat harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            karbohidratMakanan = textField.text!
        }
        
        enableSaveButton()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let textFieldRow = textField.tag
        
        if textFieldRow == 1 {
            if porsiMakanan != "" {
                textField.text = "\(porsiMakanan) g"
            }
        }
        else if textFieldRow == 2 {
            if kaloriMakanan != "" {
                textField.text = "\(kaloriMakanan) g"
            }
        }
        else if textFieldRow == 3 {
            if lemakMakanan != "" {
                textField.text = "\(lemakMakanan) g"
            }
        }
        else if textFieldRow == 4 {
            if proteinMakanan != "" {
                textField.text = "\(proteinMakanan) g"
            }
        }
        else if textFieldRow == 5 {
            if karbohidratMakanan != "" {
                textField.text = "\(karbohidratMakanan) g"
            }
        }
        
    }
    
}
