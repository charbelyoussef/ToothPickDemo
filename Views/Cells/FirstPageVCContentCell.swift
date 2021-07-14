//
//  FirstPageVCContentCell.swift
//  ToothpickDemo (iOS)
//
//  Created by Youssef on 7/14/21.
//

import UIKit

class FirstPageVCContentCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBody: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
