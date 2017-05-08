//
//  StandardEngine.swift
//  FinalProject
//
//  Created by Moody on 5/7/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation
protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    func step() -> GridProtocol
}

class StandardEngine: EngineProtocol {
    var delegate: EngineDelegate?
    var grid: GridProtocol
    var refreshTimer: Timer?
    var refreshRate: Double = 0.0 {
        didSet {
            if (timerOn && (refreshRate > 0.0)) {
                if #available(iOS 10.0, *) {
                    refreshTimer = Timer.scheduledTimer(
                        withTimeInterval: refreshRate,
                        repeats: true
                    ) { (t: Timer) in
                        _ = self.step()
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            else {
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
        }
    }
    var timerOn = false
    var rows: Int
    var cols: Int
    private static var engine: StandardEngine = StandardEngine(rows: 10, cols: 10, refreshRate: 1.0)
    
    init(rows: Int, cols: Int, refreshRate: Double) {
        self.grid = Grid(GridSize(rows: rows, cols: cols))
        self.rows = rows
        self.cols = cols
        self.refreshRate = refreshRate
    }
    init(rows: Int, cols: Int, refreshRate: Double, cellData: [String:[[Int]]]) {
        self.grid = Grid(GridSize(rows: rows, cols: cols), cellInitializer: Grid.parseToCellInitializer(cellData: cellData))
        self.rows = rows
        self.cols = cols
        self.refreshRate = refreshRate
    }
    func step() -> GridProtocol {
        let newGrid = grid.next()
        grid = newGrid
        delegate?.engineDidUpdate(withGrid: grid)
        engineUpdateNotify()
        
        return grid
    }
    
    func updateNumRowsOrCols(rowOrCol: String, num: Int) {
        if rowOrCol == "row"
        {
            StandardEngine.engine.rows = num
            self.rows = num
        }
        else
        {
            StandardEngine.engine.cols = num
            self.cols = num
        }
        
        // Create New Grid Instance
        engineCreateNewGrid()
    }
    
    func updateAll(row: Int, col: Int, cellData: [String:[[Int]]]) {
        grid = Grid(GridSize(rows: rows, cols: cols), cellInitializer: Grid.parseToCellInitializer(cellData: cellData))
        self.rows = row
        self.cols = col
        delegate?.engineDidUpdate(withGrid: grid)
        engineUpdateNotify()
    }
    
    public func engineCreateNewGrid()
    {
        // Create New Grid Instance
        grid = Grid(GridSize(rows: self.rows, cols: self.cols))
        delegate?.engineDidUpdate(withGrid: grid)
        
        engineUpdateNotify()
    }
    
    public func engineUpdateNotify()
    {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    // MARK: Engine toggleTimer
    func toggleTimer(switchOn: Bool) {
        // set the internal switch state value to what was passed in by the function
        // need to set refreshRate equal to itself to force the didSet{} code to run
        // we want this code to run as it enables/disables the timer through the
        // invalide method
        timerOn = switchOn
        refreshRate = StandardEngine.engine.refreshRate
    }
    
    class func shared() -> StandardEngine {
        return engine
    }
    
}
