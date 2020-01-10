//
//  editProfileViewController.swift
//  NutriMe Project
//
//  Created by Leonnardo Benjamin Hutama on 10/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

class editProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var userInfo: UserInfo?
    let database = CKContainer.default().publicCloudDatabase
    
    let formatter = DateFormatter()
    let datePicker = UIDatePicker()
    
    var nameTemp = ""
    var dobTemp = ""
    var weightTemp = ""
    var heightTemp = ""
    var userAge = 0
    var caloriesNeed:Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "dd MMMM yyyy"
        dobTemp = formatter.string(from: userInfo!.dob)
        nameTemp = userInfo!.name
        weightTemp = "\(userInfo!.weight)"
        heightTemp = "\(userInfo!.height)"
        
        
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.addTarget(self, action: #selector(editProfileViewController.datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)

        // Do any additional setup after loading the view.
    }
    
    func enableDoneButton() {
        if nameTemp == "" || dobTemp == "" || weightTemp == "" || heightTemp == "" {
            doneButton.isEnabled = false
        }
        else{
            doneButton.isEnabled = true
        }
    }
    
    func getAge(){
        let calender = Calendar.current
        DispatchQueue.main.async{
            let ageComponent = calender.dateComponents([.year], from: stringToDate(self.dobTemp), to: Date())
            self.userAge = ageComponent.year!
        }
    }
    
    func harrisBenedictFormula() -> Float{
        getAge() //Mendapatkan userAge
        if userInfo!.gender == "Male" {
            let weightCal = (13.8 * weightTemp.floatValue)
            let heightCal = (5 * heightTemp.floatValue)
            let ageCal = (6.8 * Float(userAge))
            
            caloriesNeed = 66.5 + weightCal + heightCal - ageCal
        }else if userInfo!.gender == "Female" {
            let weightCal = (9.25 * weightTemp.floatValue)
            let heightCal = (1.85 * heightTemp.floatValue)
            let ageCal = (4.68 * Float(userAge))
            
            caloriesNeed = 655.1 + weightCal + heightCal - ageCal
        }
        
        return caloriesNeed
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        dobTemp = formatter.string(from: sender.date)
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileTableViewCell
        cell.txtField.text = dobTemp
//        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
    }
    
    @IBAction func doneButtonClick(_ sender: Any) {
        caloriesNeed = harrisBenedictFormula()
        
        updateRecord()
    }
    
    func updateRecord() {
        let recordID = CKRecord.ID(recordName: userInfo!.userID)
        
        database.fetch(withRecordID: recordID) { (record, error) in
            if error == nil {
                record?.setValue(self.nameTemp, forKey: "name")
                record?.setValue(self.dobTemp, forKey: "dob")
                record?.setValue(self.weightTemp.floatValue, forKey: "weight")
                record?.setValue(self.heightTemp.floatValue, forKey: "height")
                record?.setValue(self.caloriesNeed, forKey: "caloriesGoal")
                
                self.database.save(record!) { (record, error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                }
            }
        }
    }
    

}

extension editProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileTableViewCell
        if userInfo != nil {
            if indexPath.row == 0 {
                cell.txtLabel.text = "Nama"
                cell.txtField.text = "\(userInfo!.name)"
                cell.txtField.keyboardType = .default
            }
            else if indexPath.row == 1 {
                cell.txtLabel.text = "Tanggal Lahir"
                cell.txtField.text = "\(formatter.string(from: userInfo!.dob))"
                cell.txtField.text = "\(dobTemp)"
                cell.txtField.inputView = datePicker
            }
            else if indexPath.row == 2 {
                cell.txtLabel.text = "Berat Badan"
                cell.txtField.text = "\(userInfo!.weight)"
                cell.txtField.keyboardType = .numberPad
            }
            else if indexPath.row == 3 {
                cell.txtLabel.text = "Tinggi Badan"
                cell.txtField.text = "\(userInfo!.height)"
                cell.txtField.keyboardType = .numberPad
            }
        }
        cell.txtField.tag = indexPath.row
        
        return cell
    }
    
    
}

extension editProfileViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let textFieldRow = textField.tag
        
        if textFieldRow == 0 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Nama harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
            }
            nameTemp = textField.text ?? ""
            
        }
        else if textFieldRow == 1 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Tanggal Lahir harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
            }
            dobTemp = textField.text ?? ""
            
        }
        else if textFieldRow == 2 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Berat Badan harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
            }
            weightTemp = textField.text ?? ""
        }
        else if textFieldRow == 3 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Tinggi Badan harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
            }
            heightTemp = textField.text ?? ""
            
        }
        
        enableDoneButton()
    }
}

