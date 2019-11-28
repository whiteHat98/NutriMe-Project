//
//  ViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 15/11/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  
  
  @IBOutlet weak var dashboardTableView: UITableView!
  
  let nutriens:[(String,String)]=[("Lemak","Daging"),("Protein","Telur"),("Karbohidrat","Jagung")]
  
  @IBAction func profilButton(_ sender: Any) {
    performSegue(withIdentifier: "toProfil", sender: self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setUpXib()
    dashboardTableView.delegate = self
    dashboardTableView.dataSource = self
    dashboardTableView.tableFooterView = UIView()
  }

  func setUpXib(){
    dashboardTableView.register(UINib(nibName: "rekomendasiTableViewCell", bundle: nil), forCellReuseIdentifier: "cellRekomendasi")
    dashboardTableView.register(UINib(nibName: "giziTableViewCell", bundle: nil), forCellReuseIdentifier: "cellMakro")
    dashboardTableView.register(UINib(nibName: "mineralTableViewCell", bundle: nil), forCellReuseIdentifier: "cellMineral")
  }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Rekomendasi Makanan"
    case 1:
      return "Nutrisi Makro"
    case 2:
      return "Mineral"
    default:
      break
    }
    return ""
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return nutriens.count
    case 1:
      return 1
    case 2:
      return 1
    default:
      break
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 1{
      return 200
    }
    return 40
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0{
      let cell = tableView.dequeueReusableCell(withIdentifier: "cellRekomendasi", for: indexPath) as? rekomendasiTableViewCell
      print(nutriens[indexPath.row])
      cell?.lblNamaMakanan.text = nutriens[indexPath.row].1
      cell?.lblNamaMakro.text = nutriens[indexPath.row].0
      return cell!
    }else if indexPath.section == 1{
      let cell = tableView.dequeueReusableCell(withIdentifier: "cellMakro", for: indexPath) as? giziTableViewCell
      return cell!
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellMineral", for: indexPath) as? mineralTableViewCell
    return cell!
  }
  
  
}

