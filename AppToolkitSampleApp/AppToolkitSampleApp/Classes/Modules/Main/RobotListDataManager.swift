//
//  RobotListDataManager.swift
//  AppToolkitSampleApp
//
//  Created by Calvin Park on 3/29/18.
//  Copyright © 2018 Jibo Inc. All rights reserved.
//

import Foundation
import AppToolkit
import UIKit


class RobotListDataManager: NSObject {
    typealias RobotListCellAction = (RobotInfoProtocol) -> ()
    typealias RobotInfoListUpdated = () -> ()
    
    fileprivate let cellReuseId = "PrototypeCell"
    
    var didSelectCell: RobotListCellAction?
    var robotInfoList: [RobotInfoProtocol]
    
    init(robotInfoList: [RobotInfoProtocol]) {
        self.robotInfoList = robotInfoList
    }
    
    convenience override init() {
        self.init(robotInfoList: [])
    }
    
    func update(data robotInfoList: [RobotInfoProtocol], completion: RobotInfoListUpdated? = nil) {
        self.robotInfoList = robotInfoList
        completion?()
    }
    
}

extension RobotListDataManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return robotInfoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseId) ?? UITableViewCell()
        cell.selectionStyle = .none
        return cell
    }
    
}

extension RobotListDataManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = robotInfoList[indexPath.row].robotName
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectCell?(robotInfoList[indexPath.row])
    }
    
}
