//
//  SecondPageVC.swift
//  ToothpickDemo (iOS)
//
//  Created by Youssef on 7/15/21.
//

import UIKit

class SecondPageVC: UIViewController {
   
    //MARK: Outlets

    @IBOutlet weak var lblTitleValue: UILabel!
    @IBOutlet weak var lblDescriptionValue: UILabel!
    @IBOutlet weak var btnReadMore: UIButton!
    
    
    //MARK: Class Variables
    var post:Structs.Post?
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //MARK: Buttons Actions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnReadMoreAction(_ sender: Any) {
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
