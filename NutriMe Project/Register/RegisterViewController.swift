//
//  RegisterViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 18/12/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

protocol GetObject{
  func getObject(userInfo: UserInfo)
}

class RegisterViewController: UIViewController {

  
  @IBOutlet weak var txtName: UITextField!
  @IBOutlet weak var txtDob: UITextField!
  @IBOutlet weak var txtHeight: UITextField!
  @IBOutlet weak var txtWeight: UITextField!
  @IBOutlet weak var restrictionSwitch: UISwitch!
  @IBOutlet weak var btnRegister: UIButton!
  @IBOutlet weak var tableGender: UITableView!
  
  @IBOutlet var textFieldCollection: [UITextField]!
  @IBAction func registerAction(_ sender: Any) {
    createUser()
    delegate?.getObject(userInfo: user!)
    //self.dismiss(animated: true, completion: nil)
  }
  
  let gender = ["Male","Female"]
  var user: UserInfo?
  var selectedGender: Int?
  var caloriesNeed: Float?
  var userAge : Int?
  var delegate: GetObject?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      //hideKeyboardWhenTapped()
      setTabNavBar()
      setKeyboard()
      btnRegister.layer.cornerRadius = 8
      
      delegateTextField()
      tableGender.delegate = self
      tableGender.dataSource = self
    }
  
  func setTabNavBar(){
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.hidesBackButton = true
    self.tabBarController?.tabBar.isHidden = true
  }
  
  func delegateTextField(){
    txtName.delegate = self
    txtDob.delegate = self
    txtHeight.delegate = self
    txtWeight.delegate = self
  }
  
  func createUser(){
    harrisBenedictFormula()
    print(caloriesNeed!)
    user = UserInfo(name: txtName.text!, dob: stringToDate(txtDob.text!), height:txtHeight.text!.floatValue , weight:txtWeight.text!.floatValue , currCalories: 0, caloriesNeed: caloriesNeed!, activities: nil, foodRestriction: nil, reminder: nil)
    do{
//      let encodedData = try NSKeyedArchiver.archivedData(withRootObject: user!, requiringSecureCoding: false)
//      UserDefaults.standard.set(encodedData, forKey: "userInfo")
      
      UserDefaults.standard.set(true, forKey: "userInfoExist")
    }catch{
      print(error)
    }
  }
  
  func stringToDate(_ stringDate: String) -> Date{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM yyyy"
    let dob = dateFormatter.date(from: txtDob.text!)
    return dob!
  }
  
  func getAge(){
    let calender = Calendar.current
    let ageComponent = calender.dateComponents([.year], from: stringToDate(txtDob.text!), to: Date())
    userAge = ageComponent.year
  }
  
  func harrisBenedictFormula(){
    getAge() //Mendapatkan userAge
    if selectedGender == 0{
      var weightCal = (13.8 * txtWeight.text!.floatValue)
      var heightCal = (5 * txtHeight.text!.floatValue)
      var ageCal = (6.8 * Float(userAge!))
      
      caloriesNeed = 66.5 + weightCal + heightCal - ageCal
    }else if selectedGender == 1{
      var weightCal = (9.25 * txtWeight.text!.floatValue)
      var heightCal = (1.85 * txtHeight.text!.floatValue)
      var ageCal = (4.68 * Float(userAge!))
      
      caloriesNeed = 655.1 + weightCal + heightCal - ageCal
    }
  }
  
  func setKeyboard(){
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc func keyboardWillShow(notif: NSNotification){
    if let keyboardSize = (notif.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
      if self.view.frame.origin.y == 0 && (txtWeight.isEditing || txtHeight.isEditing){
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }
  
  @objc func keyboardWillHide(notif: NSNotification){
    if let keyboardSize = (notif.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
      if self.view.frame.origin.y != 0 && (txtWeight.isEditing || txtHeight.isEditing){
        self.view.frame.origin.y = 0
      }
    }
  }
}

extension RegisterViewController: UITextFieldDelegate{
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension RegisterViewController: UITableViewDelegate, UITableViewDataSource{
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedGender = indexPath.row
    self.tableGender.reloadData()
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
