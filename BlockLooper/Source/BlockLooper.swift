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

import Foundation

public typealias LoopableBlock = () -> Bool

public class BlockLooper {
    
    public class func executeBlockWithRate(rate: NSTimeInterval, block: LoopableBlock) {
        var newLoopInstance = LoopInstance(rate: rate, loopableBlock: block)
        newLoopInstance.index = self.helper.nextIndex
        newLoopInstance.endBlock = {
            loopInstance, event in
            BlockLooper.helper.scheduleLoopInstance(loopInstance)
        }
        BlockLooper.helper.scheduleLoopInstance(newLoopInstance)
    }
    
    //MARK- Singleton Methods
    
    static var helper: Helper {
        struct Static {
            static var instance: Helper?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Helper()
        }
        
        return Static.instance!
    }
    
    //MARK- Helper Classes
    
    class Helper {
        private var loopIndex = 0
        var nextIndex: Int {
            let result = self.loopIndex
            ++self.loopIndex
            return result
        }
        
        var loopInstances: LoopInstances = []
        
        func isLoopInstanceScheduled(loopInstance: LoopInstance) -> Bool {
            if let index = find(self.loopInstances, loopInstance) {
                return true
            }
            return false
        }
        
        func scheduleLoopInstance(loopInstance: LoopInstance) -> Bool {
            if self.isLoopInstanceScheduled(loopInstance) == false {
                self.loopInstances.append(loopInstance)
                loopInstance.start()
                return true
            }
            return false
        }
        
        func dismissLoopInstance(loopInstance: LoopInstance) -> Bool {
            if let index = find(self.loopInstances, loopInstance) {
                loopInstance.cleanUp()
                self.loopInstances.removeAtIndex(index)
                return true
            }
            return false
        }
    }
    
    class LoopInstance: NSObject, Equatable {
        private var rate: NSTimeInterval = 1.0
        private var loopableBlock: LoopableBlock
        private var loopTimer: NSTimer?
        private var hasStarted = false
        
        var index = 0
        var startBlock: LoopLifecycleBlock?
        var stepBlock: LoopLifecycleBlock?
        var endBlock: LoopLifecycleBlock?
        
        init(rate: NSTimeInterval, loopableBlock: LoopableBlock!) {
            self.rate = rate
            self.loopableBlock = loopableBlock
        }
        
        func start() {
            if hasStarted == false {
                hasStarted = true
                
                if let startBlock = self.startBlock {
                    startBlock(loopInstance: self, event: .Start)
                }
                
                self.loopTimer = NSTimer.scheduledTimerWithTimeInterval(self.rate, target: self, selector: "onTimerTick:", userInfo: nil, repeats: true)
            }
            else {
                if let timer = self.loopTimer {
                    timer.fire()
                }
            }
        }
        
        func stop() {
            if let timer = self.loopTimer {
                timer.invalidate()
            }
        }
        
        func cleanUp() {
            self.loopTimer = nil
            self.startBlock = nil
            self.stepBlock = nil
            self.endBlock = nil
        }
        
        func onTimerTick(sender: NSTimer!) {
            if let stepBlock = self.stepBlock {
                stepBlock(loopInstance: self, event: .Step)
            }
            
            let shouldFinish = self.loopableBlock()
            if shouldFinish {
                self.stop()
                if let endBlock = self.endBlock {
                    endBlock(loopInstance: self, event: .End)
                }
            }
        }
    }
    
    enum LoopLifecycleEvent {
        case Start, Step, End
    }
    
    typealias LoopInstances = [LoopInstance]
    typealias LoopLifecycleBlock = (loopInstance: LoopInstance, event: LoopLifecycleEvent) -> Void
}

func ==(lhs: BlockLooper.LoopInstance, rhs: BlockLooper.LoopInstance) -> Bool {
    return lhs.index == rhs.index
}
