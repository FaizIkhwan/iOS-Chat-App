//
//  CallsViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 10/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class CallsViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var callsTableView: UITableView!
    
    // MARK: - Global Variable
    let cellID = "callCell"
    var listOfCalls = [
        Call(caller : "+6017-157 5472", time : "11:22", date : "08/08/2019", type : TypeOfCall.outgoing),
        Call(caller : "+6013-381 2809", time : "03:26", date : "19/08/2019", type : TypeOfCall.incoming),
        Call(caller : "+6012-138 9090", time : "20:09", date : "20/08/2019", type : TypeOfCall.incoming),
        Call(caller : "+6017-157 5472", time : "11:22", date : "08/08/2019", type : TypeOfCall.outgoing),
        Call(caller : "+6010-240 1000", time : "15:57", date : "01/08/2019", type : TypeOfCall.incoming),
        Call(caller : "+6017-157 5472", time : "11:22", date : "08/08/2019", type : TypeOfCall.outgoing),
        Call(caller : "+60111-142 8888", time : "07:31", date : "02/08/2019", type : TypeOfCall.incoming),
        Call(caller : "+6017-157 5472", time : "11:22", date : "08/08/2019", type : TypeOfCall.outgoing),
        Call(caller : "+6017-157 5472", time : "11:22", date : "08/08/2019", type : TypeOfCall.incoming),
    ]
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callsTableView.dataSource = self
        callsTableView.delegate = self
        callsTableView.tableFooterView = UIView() // Remove extra separator in TableView
    }
}

extension CallsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfCalls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CallsTableViewCell
        let call = listOfCalls[indexPath.row]
        cell.model = call
        return cell
    }
}
