//
//  TableViewCell.swift
//  MyHealthApp
//
//  Created by Imran Rapiq on 23/5/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var phaseLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
