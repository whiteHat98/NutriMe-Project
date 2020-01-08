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
  
  let user = User(name: "Monic", weight: 61, height: 178, dob: "9 Agustus 1998")
  let userData = ["Monic","9 Agustus 1998","61 kg","178 cm"]
    override func viewDidLoad() {
        super.viewDidLoad()

      profilTableView.delegate = self
      profilTableView.dataSource = self
      
      profilTableView.tableFooterView = UIView()
    }
}

extension ProfilViewController: UITableViewDelegate, UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return profilData.count + settings.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfil", for: indexPath)
    
    if indexPath.row > 3{
      print(indexPath.row)
         cell.textLabel?.text = settings[indexPath.row - 4]
         cell.detailTextLabel?.text = ""
         cell.accessoryType = .disclosureIndicator
      return cell
    }else{
      cell.textLabel?.text = profilData[indexPath.row]
      cell.detailTextLabel?.text = userData[indexPath.row]
      
     
      
      return cell
    }
  }
  
  
}
