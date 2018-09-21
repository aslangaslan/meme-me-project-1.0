//
//  FontTableViewCell.swift
//  MemeMe
//
//  Created by Giray Gençaslan on 25.08.2018.
//  Copyright © 2018 Giray Gençaslan. All rights reserved.
//

import UIKit

class FontTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fontNameLabel: UILabel!

    func initializeUI(fontName: String){
        fontNameLabel.text = fontName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
