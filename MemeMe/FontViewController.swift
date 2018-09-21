//
//  SettingsViewController.swift
//  MemeMe
//
//  Created by Giray Gençaslan on 25.08.2018.
//  Copyright © 2018 Giray Gençaslan. All rights reserved.
//

import UIKit

let Fonts:[UIFont] = [
    UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    UIFont(name: "Verdana-Bold", size: 40)!,
    UIFont(name: "Avenir-Black", size: 40)!,
    UIFont(name: "Arial", size: 40)!
]

class FontViewController: UITableViewController {
    
    var currentFont: UIFont!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Choose a Font"
        //navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Fonts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontTableViewCell") as! FontTableViewCell
        cell.initializeUI(fontName: (Fonts[indexPath.row] as UIFont).familyName)
        
        if currentFont == Fonts[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        NotificationCenter.default.post(name: NSNotification.Name("FontChanging"), object: nil, userInfo: ["Font": (Fonts[indexPath.row] as UIFont)])
        navigationController?.popViewController(animated: true)
    }

}
