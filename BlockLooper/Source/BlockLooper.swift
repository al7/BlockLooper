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

open class BlockLooper {

    struct Static {
        static var instance: Helper?
        static var token: Int = 0
    }

    private static var __once: () = {
            Static.instance = Helper()
        }()
    
    open class func executeBlockWithRate(_ rate: TimeInterval, block: @escaping LoopableBlock) {
        let newLoopInstance = LoopInstance(rate: rate, loopableBlock: block)
        newLoopInstance.index = self.helper.nextIndex
        newLoopInstance.endBlock = {
            loopInstance, event in
            BlockLooper.helper.scheduleLoopInstance(loopInstance)
        }
        BlockLooper.helper.scheduleLoopInstance(newLoopInstance)
    }
    
    //MARK- Singleton Methods
    
    static var helper: Helper {

        _ = BlockLooper.__once
        
        return Static.instance!
    }
    
    //MARK- Helper Classes
    
    class Helper {
        fileprivate var loopIndex = 0
        var nextIndex: Int {
            let result = self.loopIndex
            self.loopIndex += 1
            return result
        }
        
        var loopInstances: LoopInstances = []
        
        func isLoopInstanceScheduled(_ loopInstance: LoopInstance) -> Bool {
            if let _ = self.loopInstances.index(of: loopInstance) {
                return true
            }
            return false
        }
        
        func scheduleLoopInstance(_ loopInstance: LoopInstance) -> Bool {
            if self.isLoopInstanceScheduled(loopInstance) == false {
                self.loopInstances.append(loopInstance)
                loopInstance.start()
                return true
            }
            return false
        }
        
        func dismissLoopInstance(_ loopInstance: LoopInstance) -> Bool {
            if let index = self.loopInstances.index(of: loopInstance) {
                loopInstance.cleanUp()
                self.loopInstances.remove(at: index)
                return true
            }
            return false
        }
    }
    
    class LoopInstance: NSObject {
        fileprivate var rate: TimeInterval = 1.0
        fileprivate var loopableBlock: LoopableBlock
        fileprivate var loopTimer: Timer?
        fileprivate var hasStarted = false
        
        var index = 0
        var startBlock: LoopLifecycleBlock?
        var stepBlock: LoopLifecycleBlock?
        var endBlock: LoopLifecycleBlock?
        
        init(rate: TimeInterval, loopableBlock: LoopableBlock!) {
            self.rate = rate
            self.loopableBlock = loopableBlock
        }
        
        func start() {
            if hasStarted == false {
                hasStarted = true
                
                if let startBlock = self.startBlock {
                    startBlock(self, .start)
                }
                
                self.loopTimer = Timer.scheduledTimer(timeInterval: self.rate, target: self, selector: #selector(LoopInstance.onTimerTick(_:)), userInfo: nil, repeats: true)
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
        
        func onTimerTick(_ sender: Timer!) {
            if let stepBlock = self.stepBlock {
                stepBlock(self, .step)
            }
            
            let shouldFinish = self.loopableBlock()
            if shouldFinish {
                self.stop()
                if let endBlock = self.endBlock {
                    endBlock(self, .end)
                }
            }
        }
    }
    
    enum LoopLifecycleEvent {
        case start, step, end
    }
    
    typealias LoopInstances = [LoopInstance]
    typealias LoopLifecycleBlock = (_ loopInstance: LoopInstance, _ event: LoopLifecycleEvent) -> Void
}

func ==(lhs: BlockLooper.LoopInstance, rhs: BlockLooper.LoopInstance) -> Bool {
    return lhs.index == rhs.index
}
