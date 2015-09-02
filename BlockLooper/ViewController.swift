/*

Copyright (c) 2015 - Alex Leite (al7dev)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

import UIKit

class ViewController: UIViewController {

    var sampleSquare: UIView?
    var columns = 5
    var rows: Int { return self.columns }
    var cellSpan: CGFloat = 0.0
    
    override func loadView() {
        self.view = UIView(frame: UIScreen.mainScreen().bounds)
        self.view.backgroundColor = UIColor.whiteColor()
        
        let screenSize = UIScreen.mainScreen().bounds.size
        let squareSpan = min(screenSize.width, screenSize.height) - 100.0
    
        self.sampleSquare = UIView(frame: CGRectMake(0.0, 0.0, squareSpan, squareSpan))
        self.sampleSquare!.layer.borderColor = UIColor.blueColor().CGColor
        self.sampleSquare!.layer.borderWidth = 1.0
        self.sampleSquare!.center = self.view.center
        
        self.view.addSubview(self.sampleSquare!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cellSpan = self.sampleSquare!.frame.size.width / CGFloat(self.columns)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.performSampleCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK- Helper Methods
    
    private func performSampleCode() {

        //--- HERE IS HOW TO USE THE COMPONENT:
        var cellI = 0
        let totalCells = self.columns * self.rows
        let colorIncrement = 1.0 / CGFloat(totalCells)
        var currentColorShade: CGFloat = 0.0
        
        BlockLooper.executeBlockWithRate(0.1) {
            [unowned self] in
            
            let columnI = cellI % self.columns
            let rowI = Int(floor(Double(cellI) / Double(self.rows)))
            
            let newLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.cellSpan, height: self.cellSpan))
            newLabel.textColor = UIColor.blueColor()
            newLabel.font = UIFont.boldSystemFontOfSize(24.0)
            newLabel.textAlignment = .Center
            newLabel.text = "\(cellI)"
            newLabel.layer.borderColor = UIColor.blueColor().CGColor
            newLabel.layer.borderWidth = 1.0
            newLabel.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: currentColorShade)
            newLabel.alpha = 0.0
            
            self.sampleSquare!.addSubview(newLabel)
            
            UIView.animateWithDuration(0.5) {
                var newFrame = newLabel.frame
                newFrame.origin.x = self.cellSpan * CGFloat(columnI)
                newFrame.origin.y = self.cellSpan * CGFloat(rowI)
                newLabel.frame = newFrame
                newLabel.alpha = 1.0
            }
            
            cellI++
            currentColorShade += colorIncrement
            if cellI >= totalCells {
                return true
            }
            else {
                return false
            }
        }
    }
    
}

