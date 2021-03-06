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
    @IBOutlet weak var vTitleContainer: UIView!
    
    var isExpanded = false
    
    //MARK: Class Variables
    var post:Structs.Post?
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK: Custom Methods
    func initViews(){
        lblTitleValue.text = post?.title
        lblDescriptionValue.text = post?.body
        
        vTitleContainer.layer.borderWidth = 1
        vTitleContainer.layer.borderColor = UIColor(hexString: "#F4F4F4").cgColor
        
        vTitleContainer.addShadow(radius: 3.0,
                                  offset: CGSize(width: 0.0, height: 0.0),
                                  color: UIColor(hexString: "#000029"),
                                  opacity: 0.1)
    }

    //MARK: Buttons Actions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnReadMoreAction(_ sender: Any) {
        isExpanded = !isExpanded
        
        if isExpanded {
            lblDescriptionValue.numberOfLines = 0
            lblDescriptionValue.sizeToFit()
            btnReadMore.setTitle("Hide", for: .normal)
        }
        else{
            lblDescriptionValue.numberOfLines = 2
            lblDescriptionValue.frame.size.height = 40
            btnReadMore.setTitle("Read More", for: .normal)
        }
        
        view.layoutIfNeeded()
    }

}
