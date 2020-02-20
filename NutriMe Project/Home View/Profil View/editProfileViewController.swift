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
    var carbohydrateNeed:Float = 0
    var proteinNeed: Float = 0
    var fatNeed: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTapped()
        
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
    
    //    func harrisBenedictFormula() -> Float{
    //        getAge() //Mendapatkan userAge
    //        if userInfo!.gender == "Male" {
    //            let weightCal = (13.8 * weightTemp.floatValue)
    //            let heightCal = (5 * heightTemp.floatValue)
    //            let ageCal = (6.8 * Float(userAge))
    //
    //            caloriesNeed = 66.5 + weightCal + heightCal - ageCal
    //        }else if userInfo!.gender == "Female" {
    //            let weightCal = (9.25 * weightTemp.floatValue)
    //            let heightCal = (1.85 * heightTemp.floatValue)
    //            let ageCal = (4.68 * Float(userAge))
    //
    //            caloriesNeed = 655.1 + weightCal + heightCal - ageCal
    //        }
    //
    //        return caloriesNeed
    //    }
    
    func brocaFormula() -> Float {
        var caloriesNeeded: Float = 0
        
        getAge()
        
        //Perhitungan Berat Ideal
        var BBI:Float = (heightTemp.floatValue - 100)
        
        if userInfo!.gender == "Male" {
            //Laki" kurang dari 160 cm tidak dikurang 10%
            if heightTemp.floatValue >= 160 {
                BBI = BBI - (BBI * 0.1)
            }
            
            let statusGizi: Float = (weightTemp.floatValue/BBI) * 100
            let basalCalories: Float = BBI * 30
            
            print(statusGizi)
            print(basalCalories)
            
            //Koreksi kebutuhan kalori
            if statusGizi < 90 { //Kekurusan
                caloriesNeeded = basalCalories + (basalCalories * 0.2)
            }
            else if statusGizi > 110 && statusGizi <= 120 { //kelebihan
                caloriesNeeded = basalCalories - (basalCalories * 0.1)
            }
            else if statusGizi > 120 { // kegemukan
                caloriesNeeded = basalCalories - (basalCalories * 0.2)
            }
            else{
                caloriesNeeded = basalCalories
            }
            
        }else if userInfo!.gender == "Female" {
            //wanita kurang dari 150 cm tidak dikurang 10%
            if heightTemp.floatValue >= 150 {
                BBI = BBI - (BBI * 0.15)
            }
            
            let statusGizi: Float = (weightTemp.floatValue/BBI) * 100
            let basalCalories: Float = BBI * 25
            
            //Koreksi kebutuhan kalori
            if statusGizi < 90 { //Kekurusan
                caloriesNeeded = basalCalories + (basalCalories * 0.2)
            }
            else if statusGizi > 110 && statusGizi <= 120 { //kelebihan
                caloriesNeeded = basalCalories - (basalCalories * 0.1)
            }
            else if statusGizi > 120 { // kegemukan
                caloriesNeeded = basalCalories - (basalCalories * 0.2)
            }
            else{
                caloriesNeeded = basalCalories
            }
        }
        
        getMakroGoal(caloriesNeed: caloriesNeeded)
        
        return caloriesNeeded
    }
    
    func getMakroGoal(caloriesNeed: Float) {
        // 60% Karbohidrat (4 kalori / gram)
        carbohydrateNeed = (0.6 * caloriesNeed) / 4
        
        // 15% Protein (4 kalori / gram
        proteinNeed = (0.15 * caloriesNeed) / 4
        
        // 35% Lemak (9 kalori / gram)
        fatNeed = (0.35 * caloriesNeed) / 9
    }
    
    
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        dobTemp = formatter.string(from: sender.date)
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditProfileTableViewCell
        cell.txtField.text = dobTemp
    }
    
    @IBAction func doneButtonClick(_ sender: Any) {
        updateRecord()
    }
    
    func updateRecord() {
        
        caloriesNeed = brocaFormula()
        
        let recordID = CKRecord.ID(recordName: userInfo!.userID)
        
        database.fetch(withRecordID: recordID) { (record, error) in
            if error == nil {
                record?.setValue(self.nameTemp, forKey: "name")
                record?.setValue(self.dobTemp, forKey: "dob")
                record?.setValue(self.weightTemp.floatValue, forKey: "weight")
                record?.setValue(self.heightTemp.floatValue, forKey: "height")
                record?.setValue(self.caloriesNeed, forKey: "caloriesGoal")
                record?.setValue(self.carbohydrateNeed, forKey: "carbohydrateGoal")
                record?.setValue(self.fatNeed, forKey: "fatGoal")
                record?.setValue(self.proteinNeed, forKey: "proteinGoal")
                
                self.database.save(record!) { (record, error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.userInfo?.name = self.nameTemp
                            self.userInfo?.dob = stringToDate(self.dobTemp)
                            self.userInfo?.weight = self.weightTemp.floatValue
                            self.userInfo?.height = self.heightTemp.floatValue
                            self.userInfo?.caloriesGoal = self.caloriesNeed
                            self.userInfo?.carbohydrateGoal = self.carbohydrateNeed
                            self.userInfo?.proteinGoal = self.proteinNeed
                            self.userInfo?.fatGoal = self.fatNeed
                            
                            //                            print(self.userInfo)
                            //                            let prevVC = ProfilViewController()
                            //                            prevVC.userInfo = self.userInfo
                            //                            print(prevVC.userInfo)
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
            cell.selectionStyle = .none
            
            if indexPath.row == 1 {
                cell.txtField.tintColor = .clear
            }
            
            if indexPath.row == 0 {
                cell.txtLabel.text = "Name"
                cell.txtField.text = "\(userInfo!.name)"
                cell.txtField.keyboardType = .default
            }
            else if indexPath.row == 1 {
                cell.txtLabel.text = "Date of birth"
                cell.txtField.text = "\(formatter.string(from: userInfo!.dob))"
                cell.txtField.text = "\(dobTemp)"
                cell.txtField.inputView = datePicker
            }
            else if indexPath.row == 2 {
                cell.txtLabel.text = "Weight"
                cell.txtField.text = "\(userInfo!.weight)"
                cell.txtField.keyboardType = .numberPad
            }
            else if indexPath.row == 3 {
                cell.txtLabel.text = "Height"
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

