//
//  RegisterViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 18/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

protocol GetObject{
    func getObject(userInfo: UserInfo)
}

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDob: UITextField!
    @IBOutlet weak var txtHeight: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var tableGender: UITableView!
    
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBAction func registerAction(_ sender: Any) {
        createUser()
        delegate?.getObject(userInfo: user!)
        //self.dismiss(animated: true, completion: nil)
    }
    
    var email: String?
    var password: String?
    
    let gender = ["Male","Female"]
    var user: UserInfo?
    var selectedGender: Int?
    var caloriesNeed: Float?
    var carbohydrateNeed: Float?
    var fatNeed: Float?
    var proteinNeed: Float?
    var userAge : Int?
    var delegate: GetObject?
    
    var weightCal = Float()
    var heightCal = Float()
    var ageCal = Float()
    
    var nameText = String()
    var dobText = String()
    var heightText = String()
    var weightText = String()
    
    let database = CKContainer.default().publicCloudDatabase
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBAction func doneButtonClick(_ sender: Any) {
        
        doneButton.isEnabled = false
        indicator.isHidden = false
        caloriesNeed = brocaFormula()
        
        let record = CKRecord(recordType: "User")
        
        record.setValue(nameText, forKey: "name")
        record.setValue(dobText, forKey: "dob")
        record.setValue(heightText.floatValue, forKey: "height")
        record.setValue(weightText.floatValue, forKey: "weight")
        record.setValue(caloriesNeed, forKey: "caloriesGoal")
        record.setValue(carbohydrateNeed, forKey: "carbohydrateGoal")
        record.setValue(fatNeed, forKey: "fatGoal")
        record.setValue(proteinNeed, forKey: "proteinGoal")
        record.setValue(8, forKey: "mineralGoal")
        record.setValue("no value", forKey: "userReminderID")
        record.setValue("no value", forKey: "userRestrictionID")
        record.setValue(self.email ?? "", forKey: "email")
        record.setValue(self.password ?? "", forKey: "password")
        record.setValue([], forKey: "restrictions")
        
        if selectedGender == 0 {
            record.setValue("Male", forKey: "gender")
        }
        else{
            record.setValue("Female", forKey: "gender")
        }
        
        database.save(record) { (record, error) in
            
            if error == nil {
                print("Record Saved. ID = \(record!.recordID.recordName)")
                
                let userID: String = record!.recordID.recordName
                UserDefaults.standard.setValue(userID, forKey: "currentUserID")
                UserDefaults.standard.set(true, forKey: "needUpdate")
               // self.createUser()
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "userInfoExist")
                    
                    let dashboard : UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "dashboard") as! UITabBarController
                    self.navigationController?.isNavigationBarHidden = true
                    self.show(dashboard, sender: self)
                    //self.navigationController?.pushViewController(dashboard, animated: true)
                    //self.performSegue(withIdentifier: "segueToDashboard", sender: nil)
                }
                
                
            }
            else{
                print("Record Not Saved \(error)")
            }
        }
    }
    
    
    
    //MARK: VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hideKeyboardWhenTapped()
        
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        
        datePicker.addTarget(self, action: #selector(RegisterViewController.datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        
        setTabNavBar()
        setKeyboard()
        btnRegister.layer.cornerRadius = 8
        
        delegateTextField()
        tableGender.delegate = self
        tableGender.dataSource = self
        
        txtHeight.keyboardType = UIKeyboardType.numberPad
        txtWeight.keyboardType = UIKeyboardType.numberPad
        txtDob.inputView = datePicker
        
        enableDoneButton()
        
    }
    
    
    //MARK: FUNCTIONS
    
    func setTabNavBar(){
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        //self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func delegateTextField(){
        txtName.delegate = self
        txtDob.delegate = self
        txtHeight.delegate = self
        txtWeight.delegate = self
    }
    
    func createUser(){
        print(caloriesNeed)
        let userID: String = UserDefaults.standard.value(forKey: "currentUserID") as! String
        var gender = String()
        if selectedGender == 0 {
            gender = "Male"
        }
        else{
            gender = "Female"
        }
        
        //        user = UserInfo(userID: userID, name: nameText, dob: stringToDate(dobText), gender: gender, height: heightText.floatValue, weight: weightText.floatValue, currCalories: 0, currCarbo: 0, currProtein: 0, currFat: 0, currMineral: 0, activityCalories: 0, caloriesGoal: caloriesNeed, carbohydrateGoal: 123, fatGoal: 123, proteinGoal: 123, mineralGoal: 123)
        
        //        do{
        //            //      let encodedData = try NSKeyedArchiver.archivedData(withRootObject: user!, requiringSecureCoding: false)
        //            //      UserDefaults.standard.set(encodedData, forKey: "userInfo")
        //
        //            UserDefaults.standard.set(true, forKey: "userInfoExist")
        //        }catch{
        //            print(error)
        //        }
    }
    
    
    
    func getAge(){
        let calender = Calendar.current
        DispatchQueue.main.async{
            let ageComponent = calender.dateComponents([.year], from: stringToDate(self.txtDob.text!), to: Date())
            self.userAge = ageComponent.year
        }
    }
    
    
    func harrisBenedictFormula() -> Float{
        getAge() //Mendapatkan userAge
        if selectedGender == 0{
            weightCal = (13.8 * txtWeight.text!.floatValue)
            heightCal = (5 * txtHeight.text!.floatValue)
            ageCal = (6.8 * Float(userAge ?? 0))
            
            caloriesNeed = 66.5 + weightCal + heightCal - ageCal
        }else if selectedGender == 1{
            weightCal = (9.25 * txtWeight.text!.floatValue)
            heightCal = (1.85 * txtHeight.text!.floatValue)
            ageCal = (4.68 * Float(userAge!))
            
            caloriesNeed = 655.1 + weightCal + heightCal - ageCal
        }
        
        return caloriesNeed!
    }
    
    func brocaFormula() -> Float {
        var caloriesNeeded: Float = 0

        getAge()
        print(weightText)
        print(heightText)
        print(selectedGender)
        
        //Perhitungan Berat Ideal
        var BBI:Float = (heightText.floatValue - 100)
        
        if selectedGender == 0 {
            //Laki" kurang dari 160 cm tidak dikurang 10%
            if heightText.floatValue >= 160 {
                BBI = BBI - (BBI * 0.1)
            }
            
            let statusGizi: Float = (weightText.floatValue/BBI) * 100
            let basalCalories: Float = BBI * 30
            
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
            
        }else if selectedGender == 1 {
            //wanita kurang dari 150 cm tidak dikurang 10%
            if heightText.floatValue >= 150 {
                BBI = BBI - (BBI * 0.15)
            }
            
            let statusGizi: Float = (weightText.floatValue/BBI) * 100
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
        print(caloriesNeeded)
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
    
    func setKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        txtDob.text = formatter.string(from: sender.date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notif: NSNotification){
        if let keyboardSize = (notif.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y == 0 && (txtWeight.isEditing || txtHeight.isEditing){
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func enableDoneButton() {
        if nameText == "" || dobText == "" || selectedGender == nil || heightText == "" || weightText == "" {
            doneButton.isEnabled = false
        }
        else{
            doneButton.isEnabled = true
        }
    }
    
    @objc func keyboardWillHide(notif: NSNotification){
        if let keyboardSize = (notif.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y != 0 && (txtWeight.isEditing || txtHeight.isEditing){
                self.view.frame.origin.y = 0
            }
        }
    }}

//MARK: EXTENSIONS

extension RegisterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let textFieldRow = textField.tag
        
        if textFieldRow == 0 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Nama harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
            }
            nameText = txtName.text ?? ""
        }
        
        if textFieldRow == 1 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Tanggal Lahir harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
            }
            dobText = txtDob.text ?? ""
        }
        
        if textFieldRow == 2 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Tinggi Badan harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
            }
            heightText = txtHeight.text ?? ""
        }
        
        if textFieldRow == 3 {
            if textField.text == "" {
                textField.attributedPlaceholder = NSAttributedString(string: "Berat Badan harus diisi", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
            }
            weightText = txtWeight.text ?? ""
        }
        
        enableDoneButton()
    }
}

extension RegisterViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGender = indexPath.row
        self.tableGender.reloadData()
        enableDoneButton()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genderCell")
        cell?.textLabel?.text = gender[indexPath.row]
        cell?.accessoryType = .none
        
        if selectedGender != nil && selectedGender == indexPath.row{
            cell?.accessoryType = .checkmark
        }
        return cell!
    }
}

extension String{
    var floatValue: Float{
        return (self as NSString).floatValue
    }
}

extension UIViewController {
    func hideKeyboardWhenTapped(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
}
