//
//  MealPlanView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 12/1/24.
//

import UIKit

class MealPlanView: UIViewController{
    //Outlets
    @IBOutlet weak var mealPlanLable: UILabel!
    @IBOutlet weak var mealPlanTableView: UITableView!
    
    //Data
    var mealPlan: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealPlan = generateMealPlan()
        mealPlanTableView.reloadData()
    }
    
    func generateMealPlan() -> [String] {
        return ["Apples and Toast", "Chicken and Rice", "Oatmeal with berries"]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mealPlan.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
        cell.textLabel?.text = mealPlan[indexPath.row]
        return cell
    }
    
}
