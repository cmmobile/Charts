//
//  CMDemoListViewController.swift
//  CMDemo
//
//  Created by cm0673 on 2022/2/23.
//  Copyright © 2022 dcg. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif

private struct ItemDef {
    let title: String
    let subtitle: String
    let `class`: AnyClass
}

class CMDemoListViewController: UIViewController {
    
    var tableView: UITableView!
    private var itemDefs = [ItemDef(title: "即時走勢線圖",
                            subtitle: "分段顏色實作",
                            class: CMLineChart1ViewController.self)
    ]
    
    override func loadView() {
        let table = UITableView()
        self.tableView = table
        table.dataSource = self
        table.delegate = self
        self.view = table
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Charts Demonstration"
        self.tableView.rowHeight = 70
        //FIXME: Add TimeLineChart
        
    }
}

extension CMDemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemDefs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let def = self.itemDefs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = def.title
        cell.detailTextLabel?.text = def.subtitle
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let def = self.itemDefs[indexPath.row]
        
        let vcClass = def.class as! UIViewController.Type
        let vc = vcClass.build()
        
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
