//
//  LoginViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 21/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit
import CloudKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var flag = false
    let database = CKContainer.default().publicCloudDatabase
    
    @IBAction func loginBtn(_ sender: Any) {
        validateData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad() 
            self.txtPassword.isSecureTextEntry = true
            self.hideKeyboardWhenTapped()
            setTabNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if !CheckInternet.Connection(){
//            let alert = UIAlertController(title: "Internet Connection", message: "Internet connection required please check your internet connection!", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//            self.present(alert, animated: true, completion: nil)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRegister"{
            let nextVC = segue.destination as! RegisterViewController
            nextVC.email = self.txtEmail.text
            nextVC.password = self.txtPassword.text
        }
    }
    func validateData(){
        if txtEmail.text!.isEmpty || txtPassword.text!.isEmpty {
            let alert = UIAlertController(title: "Login Fail", message: "Please fill the Email and Password for Login!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else{
            if isEmail(txtEmail.text!){
                //cek email di db
                checkEmailInDB(email: txtEmail.text!)
            }else{
                let alert = UIAlertController(title: "Email not valid", message: "Please input a valid email!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setTabNavBar(){
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationItem.hidesBackButton = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    func isEmail(_ email : String) -> Bool{
        let emailRegX = "[A-Za-z0-9._%+-]+@[A-Za-z.-]+\\.[A-Za-z]{2,64}"
        let emailPres = NSPredicate(format: "SELF MATCHES %@", emailRegX)
        return emailPres.evaluate(with: email)
    }
    
    func checkEmailInDB(email: String){
        let predicate = NSPredicate(format: "email == %@", email)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (records, err) in
            if err != nil{
                print(err)
            }else{
                if records!.isEmpty{
                    print("test")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Hello!", message: "Let's complete your personal information!", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            self.performSegue(withIdentifier: "toRegister", sender: self)
                        }))
                        
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    //sudah pernah daftar
                    
                    guard let record = records?[0] else{return}
                    DispatchQueue.main.async {
                        if self.txtPassword.text == record.value(forKey: "password") as! String{
                            UserDefaults.standard.setValue(record.recordID.recordName, forKey: "currentUserID")
                            UserDefaults.standard.set(true, forKey: "userInfoExist")
                            let dashboard : UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "dashboard") as! UITabBarController
                            self.navigationController?.isNavigationBarHidden = true
                            self.show(dashboard, sender: self)
                        }else{
                            let alert = UIAlertController(title: "Wrong password", message: "Please input the right password!", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
