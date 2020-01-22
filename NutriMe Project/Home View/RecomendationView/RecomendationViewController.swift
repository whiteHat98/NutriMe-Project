//
//  RecomendationViewController.swift
//  NutriMe Project
//
//  Created by Randy Noel on 22/01/20.
//  Copyright © 2020 whiteHat. All rights reserved.
//

import UIKit

class RecomendationViewController: UIViewController {

    
    @IBOutlet weak var recomendationTable: UITableView!
    
    var numberRow: Int = 0
    var macroCategory: String!
    var listForTable: [String] = []
    var listCarb : [String] = []
    var listProt : [String] = []
    var listFat : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard macroCategory != nil else {return}
        if macroCategory == "carb"{
            //isi list
            self.navigationItem.title = "Carbohydrates"
            listCarb.append("Rice")
            inputToListTable(list: listCarb)
            
        }else if macroCategory == "prot"{
            //isilist
            self.navigationItem.title = "Protein"
            listProt.append("Egg")
            inputToListTable(list: listProt)
            
        }else if macroCategory == "fat"{
            //isilist
            self.navigationItem.title = "Fat"
            listFat.append("Chicken")
            inputToListTable(list: listFat)
        }
        
        
        recomendationTable.delegate = self
        recomendationTable.dataSource = self
        recomendationTable.tableFooterView = UIView()
    }
    
    func inputToListTable(list: [String]){
        self.listForTable.removeAll()
        self.listForTable = list
        numberRow = listForTable.count
    }
    

}

extension RecomendationViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRecomendation", for: indexPath)
        
        cell.textLabel?.text = listForTable[indexPath.row]
        
        return cell
    }
    
    
}
