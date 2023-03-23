//
//  ListViewController.swift
//  TravelBook
//
//  Created by Mehmet Sukru Kavak on 23.03.2023.
//

import UIKit

class ListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    
    @objc func addButtonClicked(){
        performSegue(withIdentifier: "toMapPage", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = "Text"
        
        return cell
    }
}
