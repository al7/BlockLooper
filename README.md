BlockLooper
=====================

### About

This is a helper class that allows you to easily execute a closure on a loop, at a certain rate, until you tell it to stop. It's is very useful for creating, for instance, quick sequential animations using *UIKit*. To better understand what this class does, run the sample project on the iPhone Simulator, then look at the source code. 

### Sample Code

Using this class is pretty simple and straight-forward. You just need to run the following code:

```swift
//-- Scheduling a loopable closure:

BlockLooper.executeBlockWithRate(0.5) {
	
	// loop code goes here...
	
	return true 
}
```

In the function call, ```rate``` corresponds to the *NSTimeInterval* value of the frequency in which the closure should be looped. In the sample above, the closure will be executed once, and then stop.  

The closure signature is: ```() -> Bool ```, where the return value indicates if the loop should be interrupted. In the sample below, we are running the loop 10 times until it stops:

```swift
var loopI = 0

BlockLooper.executeBlockWithRate(0.5) {

	println("Loop i: \(loopI)")
	++loopI

	return (loopI >= 10)
}
```
You can also execute multiple loops at once. 

### How to install

To use this control, you can either copy the [*BlockLooper.swift*](BlockLooper/Source/BlockLooper.swift) file to your project (you can find it at the '[Source](BlockLooper/Source)' folder of this project), or add the following pod to your Podfile, using CocoaPods 0.36 and up:

```
pod 'BlockLooper'
```

### License

This component is available under MIT license.
