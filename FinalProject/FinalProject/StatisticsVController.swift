//
//  StatisticsVController.swift
//  FinalProject
//

//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

//ICON Ref: https://cdn1.iconfinder.com/data/icons/presentation-ios/64/pre-col-graph-increase-512.png

import UIKit

class StatisticsVController: UIViewController {
    @IBOutlet weak var aliveC: UILabel!
    
    @IBOutlet weak var bornC: UILabel!
    
    @IBOutlet weak var deadC: UILabel!
    
    var engine: StandardEngine!
    @IBOutlet weak var emptyC: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.shared()
        updateC(withGrid: engine.grid)
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.updateC(withGrid: self.engine.grid)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func updateC(withGrid: GridProtocol) {
        
        var aliveCount = 0
        var bornCount = 0
        var deadCount = 0
        var emptyCount = 0
        
        (0 ..< withGrid.size.rows).forEach { i in
            (0 ..< withGrid.size.cols).forEach { j in
                
                switch withGrid[j,i].description()
                {
                case "alive":
                    aliveCount = aliveCount + 1
                case "born":
                    bornCount = bornCount + 1
                case "dead":
                    deadCount = deadCount + 1
                default:
                    emptyCount = emptyCount + 1
                }
            }
        }
        aliveC.text = String(aliveCount)
        bornC.text = String(bornCount)
        deadC.text = String(deadCount)
        emptyC.text = String(emptyCount)
    }

}
