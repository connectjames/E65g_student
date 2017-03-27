//
//  GridView.swift
//  Assignment3
//
//  Created by Moody on 24/03/2017.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable

class GridView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var createGrid = Grid(0, 0)
    
    @IBInspectable var size: Int = 20 {
        willSet {
            createGrid = Grid(size, size)
        }
    }

    @IBInspectable var livingColor: UIColor = UIColor.purple
    @IBInspectable var emptyColor: UIColor = UIColor.gray
    @IBInspectable var bornColor: UIColor = UIColor.red
    @IBInspectable var diedColor: UIColor = UIColor.blue
    @IBInspectable var gridColor: UIColor = UIColor.black
    
    @IBInspectable var gridWidth: CGFloat = CGFloat(2.0)
    
    override func draw(_ rect: CGRect) {
    
        let size = CGSize(
            width: rect.size.width / CGFloat(self.size),
            height: rect.size.height / CGFloat(self.size)
        )
        let base = rect.origin
        
        (0 ..< self.size).forEach { i in
            (0 ..< self.size).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(i) * size.width),
                    y: base.y + (CGFloat(j) * size.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: size
                )
                
                let cellPath = UIBezierPath(ovalIn: subRect)
                switch createGrid[(i, j)] {
                    case .alive: livingColor.setFill()
                    case .empty: emptyColor.setFill()
                    case .born: bornColor.setFill()
                    case .died: diedColor.setFill()
                }
                cellPath.fill()
            }
            
            (0 ... self.size).forEach {
                drawLine(
                    from: CGPoint(
                        x: rect.origin.x + (CGFloat($0) * size.width),
                        y: rect.origin.y
                    ),
                    to: CGPoint(
                        x: rect.origin.x + (CGFloat($0) * size.width),
                        y: rect.origin.y + rect.size.height
                    )
                )
                drawLine(
                    from: CGPoint(
                        x: rect.origin.x,
                        y: rect.origin.y + (CGFloat($0) * size.height)
                    ),
                    to: CGPoint(
                        x: rect.origin.x + rect.size.width,
                        y: rect.origin.y + (CGFloat($0) * size.height)
                    )
                )
            }
        }
    }
    
    func drawLine(from start:CGPoint, to end: CGPoint) {
        
        //create the path
        let gridPath = UIBezierPath()
        
        //set the path's line width to the height of the stroke
        gridPath.lineWidth = gridWidth
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        gridPath.move(to: start)
        
        //add a point to the path at the end of the stroke
        gridPath.addLine(to: end)
        
        //draw the stroke
        gridColor.setStroke()
        gridPath.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    typealias Position = (row: Int, col: Int)
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        createGrid[pos] = createGrid[pos].isAlive ? .empty : .alive
        
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position {
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let row = touchX / gridWidth * CGFloat(self.size)
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let col = touchY / gridHeight * CGFloat(self.size)
        let position = (row: Int(row), col: Int(col))
        return position
    }
}
