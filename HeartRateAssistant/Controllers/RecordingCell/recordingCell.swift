//
//  recordingCell.swift
//  HeartRateAssistant
//
//  Created by mymac on 2021/1/13.
//  Copyright © 2021 iOS. All rights reserved.
//

import UIKit

class recordingCell: UITableViewCell {

    
    @IBOutlet weak var cellContainer: UIView!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var bloodPressureLbl: UILabel!
    @IBOutlet weak var pulseLbl: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var resultEmotiLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var keyContainer: UIView!
    @IBOutlet weak var mapKeyBtn: UIButton!
    @IBOutlet weak var keyImg: UIImageView!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
