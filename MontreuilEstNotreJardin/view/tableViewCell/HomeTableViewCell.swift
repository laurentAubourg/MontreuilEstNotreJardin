//
//  HomeTableViewCell.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 19/02/2022.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
