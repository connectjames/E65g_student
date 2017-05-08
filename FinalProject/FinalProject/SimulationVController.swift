//
//  SimulationVController.swift
//  FinalProject
//
//  Created by Moody on 5/6/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
// ICON Ref : https://cdn2.iconfinder.com/data/icons/virtual-reality-1/500/VR_10-512.png

import UIKit

class SimulationVController: UIViewController, GridViewDataSource, EngineDelegate {
    
    var engine: StandardEngine!
    var delegate: EngineDelegate?
    
    var refreshRate: Double = 0.0
    var rows: Int = 10
    var cols: Int = 10
    
    @IBOutlet weak var gridView: GridView!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var resetBtn: UIButton!
    
    @IBOutlet weak var stepBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        stepBtn.layer.cornerRadius = stepBtn.frame.width / 2
        engine = StandardEngine.shared()
        engine.delegate = self
        gridView.drawGrid = self
        
        // Make sure that the SimulationViewController knows about updated row/col size
        // before first time displayed
        self.gridView.gridRows = engine.rows
        self.gridView.gridCols = engine.cols
        gridView.setNeedsDisplay()

    }
    
    @IBAction func stepClickFunc(_ sender: UIButton) {
        engine.grid = engine.step()
    }

    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.gridRows = StandardEngine.shared().rows
        self.gridView.gridCols = StandardEngine.shared().cols
        self.gridView.setNeedsDisplay()
    }
    
    @IBAction func saveClickFunc(_ sender: UIButton) {
        print("?? What!")
        
        let saveAlertController = UIAlertController(title: "Add a name", message: nil, preferredStyle: .alert)
        saveAlertController.addTextField { (_) in
            
        }
        let saveAlertAction  = UIAlertAction(title: "Save", style: .default) { (_) in
            _ = InstrumentationVController()
            let tField = saveAlertController.textFields?.first?.text
            if (tField?.characters.count)! >= 1{
                if tField != nil{
                    print(tField ?? "p")
                    
//                    instrument.gridInits.append(GridInit(title: tField!, contents:self.getAllAlive(), maxDim: (Int(self.gridView.gridRows) + Int(self.gridView.gridCols)) / 2))
//                    StandardEngine.shared().updateAll(row: self.gridView.gridRows, col: self.gridView.gridCols, cellData: [tField! : self.getAllAlive()])

                    DispatchQueue.global(qos: .background).async {
                        DispatchQueue.main.async {
//                            instrument.userDefaultSetBlank()
//                            
//                            instrument.saveAllGrid(grids: instrument.gridInits)
                                                    }
                    }
                }else{
                    print("No Value")
                }
                
            }else{
                print("Too small")
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("Cancel")
        }
        saveAlertController.addAction(saveAlertAction)
        saveAlertController.addAction(cancelAction)
        present(saveAlertController, animated: true,completion: nil)

        


    }
    func getAllAlive() -> [[Int]] {
        var arr = [[Int]]()
        let size = self.gridView.gridCols
        (0 ..< size - 1).forEach { i in
            (0 ..< size - 1).forEach { j in
                // print(sampleEngine.grid[i, j])
                if(engine.grid[i, j].isAlive) {
                    arr.append([i,j])
                }
                
            }
        }
        return arr
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    @IBAction func resetClickFunc(_ sender: UIButton) {
        engine.engineCreateNewGrid()
    }
    

}
