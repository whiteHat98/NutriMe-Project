//
//  ProfilViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 15/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

struct User{
    var name : String
    var weight : Int
    var height : Int
    var dob : String
    var test: String?
}

class ProfilViewController: UIViewController {
    
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var profilTableView: UITableView!
    
    let profilData = ["Nama","Tanggal Lahir","Berat Badan","Tinggi Badan"]
    let settings = ["Pantangan Makanan","Reminders"]
    
    var userInfo: UserInfo?
    
    var userData:[String] = []
    
    var formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "dd MMMM yyyy"
        userData = [userInfo!.name, "\(formatter.string(from: userInfo!.dob))", "\(userInfo!.weight)", "\(userInfo!.height)"]
        
        
        profilTableView.delegate = self
        profilTableView.dataSource = self
        profilTableView.isScrollEnabled = false
        profilTableView.tableFooterView = UIView()
        
        profilTableView.isScrollEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToEditProfile" {
            let nextVC = segue.destination as! editProfileViewController
            nextVC.userInfo = self.userInfo
        }
        else if segue.identifier == "segueToPantanganMakanan" {
            let nextVC = segue.destination as! PantanganMakananViewController  
            nextVC.userInfo = self.userInfo
        }
    }
}

extension ProfilViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profilData.count + settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfil", for: indexPath)
        
        cell.selectionStyle = .none
        
        if indexPath.row > 3{
            print(indexPath.row)
            cell.textLabel?.text = settings[indexPath.row - 4]
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
            return cell
        }else{
            cell.textLabel?.text = profilData[indexPath.row]
            cell.detailTextLabel?.text = userData[indexPath.row]
            cell.accessoryType = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            performSegue(withIdentifier: "segueToPantanganMakanan", sender: self)
        }
        else if indexPath.row == 5 {
            performSegue(withIdentifier: "segueToReminders", sender: self)
        }

    }
}
