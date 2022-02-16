//
//  TableViewCell.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 20/01/2022.
//

import UIKit
protocol MenuDelegate{
    func categoryIsSelected(_ rank:Int)
    func categoryIsUnselected(_ rank:Int)
    func closeMenu()
    func openMenu()
}
class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    var delegate:MenuDelegate? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxBtn.imageView?.contentMode = .scaleAspectFill
            
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     
    }
    
    @IBAction func checkboxTapped(_ sender: UIButton?) {
        if checkBoxBtn.isSelected == true{
            checkBoxBtn.isSelected = false
            delegate?.categoryIsUnselected(checkBoxBtn.tag)
        }else{
            checkBoxBtn.isSelected = true
            delegate?.categoryIsSelected(checkBoxBtn.tag)
        }
    }
  
}
