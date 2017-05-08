//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Moody on 5/6/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource{
    
    @IBOutlet weak var textF: UITextField!
    var fruitValue: String?
    var gridStruct: GridInit?
    var saveClosure: ((String) -> Void)?
    var sampleEngine = StandardEngine.shared()
    var instrument = InstrumentationVController()
    
    //debuging console logs
    var debug = true
    
    @IBAction func textField(_ sender: UITextField) {
        
    }
    //gridview outlet
    @IBOutlet weak var gridView: GridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textF.text = gridStruct?.title
        navigationController?.isNavigationBarHidden = false
        gridView.drawGrid = self
        //navigationItem.title = "Grid Editor"
        if let gridStruct = gridStruct {
            sampleEngine = StandardEngine(rows: 2*gridStruct.maxDim, cols: 2*gridStruct.maxDim, refreshRate: 1, cellData: [gridStruct.title :gridStruct.contents])
            //sampleEngine.updateAll(row: 2*gridStruct.maxDim, col: 2*gridStruct.maxDim, cellData: [gridStruct.title :gridStruct.contents])
            self.gridView.gridRows = sampleEngine.rows
            self.gridView.gridCols = sampleEngine.cols
            //if contents is not empty, send to engine function to init values
            
            gridView.setNeedsDisplay()
           // print("Engine Set Grid and Contents from gridstruct")
           // gridView.lastTouchedPosition
        }
        if(debug) {
            //print("Grid rows: \(self.gridView.gridRows) Grid Cols: \(self.gridView.gridCols)")
//            print("Grid Contents: \(gridStruct?.contents)")
        }
    }

    
    @IBAction func saveBtn(_ sender: UIBarButtonItem) {
        print("Save Button click")
        //print(sampleEngine.grid[gridStruct!.maxDim * 2 - 1, gridStruct!.maxDim * 2 - 1])
        print("\(getAllAlive().count)")

        if let newValue = textF.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            var count = 0
            //self.navigationController?.popViewController(animated: true)
            //load to singleton grid
            StandardEngine.shared().updateAll(row: 2*gridStruct!.maxDim, col: 2*gridStruct!.maxDim, cellData: [gridStruct!.title : getAllAlive()])
            for i in instrument.gridInits {
                if (i.title == gridStruct!.title) {
                    //find index of value
                    instrument.gridInits.remove(at: count)
                    instrument.gridInits.append(GridInit(title: gridStruct!.title, contents: getAllAlive(), maxDim: gridStruct!.maxDim))
                }
                count = count + 1
            }
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func getAllAlive() -> [[Int]] {
        var arr = [[Int]]()
        let size = (self.gridStruct?.maxDim)! * 2
        (0 ..< size - 1).forEach { i in
            (0 ..< size - 1).forEach { j in
               // print(sampleEngine.grid[i, j])
                if(sampleEngine.grid[i, j].isAlive) {
                    arr.append([i,j])
                }
            }
        }
        return arr
    }

    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
        //navigationController?.popViewController(animated: true)
         dismiss(animated: true, completion: nil)
    }
    public subscript (row: Int, col: Int) -> CellState {
        get { return sampleEngine.grid[row,col] }
        set { sampleEngine.grid[row,col] = newValue }
    }
}
