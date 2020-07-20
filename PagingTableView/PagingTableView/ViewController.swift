//
//  ViewController.swift
//  PagingTableView
//
//  Created by Park GilNam on 2020/07/20.
//  Copyright © 2020 swieeft. All rights reserved.
//

import UIKit

struct CellData {
    let title: String
    let date: Date
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var cellDatas: [CellData] = []
    
    var isPaging: Bool = false
    var hasNextPage: Bool = false
    
    var cellHeights: [IndexPath: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        paging()
    }
    
    func paging() {
        let index = cellDatas.count
        
        var datas: [CellData] = []
        
        for i in index..<(index + 20) {
            let random = Int.random(in: 1...5)
            
            var title: String = ""
            for j in 0..<random {
                if j == 0 {
                    title = "Title\(i)"
                } else {
                    title = "\(title)\nTitle\(i)"
                }
            }
            
            let data = CellData(title: title, date: Date().addingTimeInterval(TimeInterval(86400 * i)))
            datas.append(data)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.cellDatas.append(contentsOf: datas)
            
            print(self.cellDatas.count)
            
            self.hasNextPage = self.cellDatas.count > 300 ? false : true
            self.isPaging = false
            
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 82
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cellDatas.count
        } else if section == 1 && isPaging && hasNextPage {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? MyCell else {
                return UITableViewCell()
            }
            
            let data = cellDatas[indexPath.row]
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "yyyy. MM. dd"
            
            cell.titleLabel.text = data.title
            cell.dateLabel.text = dateFormatter.string(from: data.date)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as? LoadingCell else {
                return UITableViewCell()
            }
            
            cell.start()
            
            return cell
        }
    }
}

extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offsetY > (contentHeight - height) {
            if isPaging == false && hasNextPage {
                beginPaging()
            }
        }
    }
    
    func beginPaging() {
        isPaging = true

        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paging()
        }
    }
}

class MyCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

class LoadingCell: UITableViewCell {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    func start() {
        activityIndicatorView.startAnimating()
    }
}
