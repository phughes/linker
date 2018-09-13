//
//  ViewControllerTableViewController.swift
//  LinkOpener
//
//  Created by Patrick Hughes on 9/12/18.
//  Copyright © 2018 Patrick Hughes. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    private var privateURLS: [String] = []
    var urls: [String] {
        get {
            if privateURLS.count > 0 {
                return privateURLS
            }
            return UserDefaults.standard.stringArray(forKey: "urls") ?? []
        }
        set {
            privateURLS = newValue
            UserDefaults.standard.set(newValue, forKey: "urls")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(HeaderCell.self, forHeaderFooterViewReuseIdentifier: String(describing: HeaderCell.self))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return urls.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: HeaderCell.self))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
        
        cell.textLabel?.text = urls[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: urls[indexPath.row]) else { return }
        saveURL(url)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var urls = self.urls
        
        urls.remove(at: indexPath.row)
        self.urls = urls
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    @IBAction func openLink(sender: UIButton) {
        guard let header = sender.superview as? HeaderCell else {
            return
        }
        
        guard let url = header.url(fromString: header.textField.text ?? "") else { return }
        saveURL(url)
        
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    func saveURL(_ url: URL) {
        var urls = self.urls
        
        
        let urlString = url.absoluteString
        urls.removeAll { (value) -> Bool in
            return urlString == value
        }
        
        urls.insert(urlString, at: 0)
        
        self.urls = urls
        self.tableView.reloadData()
    }
    
}

class HeaderCell: UITableViewHeaderFooterView, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var secureSwitch: UISwitch!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var viewController: ViewController!

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text as NSString? else {
            openButton.isEnabled = false
            return true
        }
        
        let result = text.replacingCharacters(in: range, with: string)
        
        if isValidUrl(url: result) {
            openButton.isEnabled = true
        }
        else {
            openButton.isEnabled = false
        }

        return true
    }
    
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
    
    func url(fromString string: String) -> URL? {
        if string.contains(".") == false {
            return nil
        }
        
        let urlString: String

        if string.lowercased().starts(with: "http") {
            urlString = string
        }
        else if secureSwitch.isOn {
            urlString = "https://" + string
        }
        else {
            urlString = "http://" + string
        }
        
        
        return URL(string: urlString)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewController.openLink(sender: openButton)
        return true
    }
}

