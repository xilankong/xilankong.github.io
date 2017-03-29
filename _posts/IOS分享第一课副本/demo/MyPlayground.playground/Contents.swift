//: Playground - noun: a place where people can play

import UIKit

//playground 的方便
var str = "Hello, playground"
print(str)

//返回元祖
func returnTwoValue() -> (Int, Int) {
    return (3, 5)
}

print(returnTwoValue())

var myClosure = {
    (input: String) in
    print("\(input)" + "1234")
}

func useTheClosure(closure: (String)->()) {
    closure("OneTwoThree")
}

useTheClosure(closure: myClosure)