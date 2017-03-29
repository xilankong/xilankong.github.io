//: Playground - noun: a place where people can play

import UIKit
import Foundation

/** playground 的方便之处 **/
let msg = "Hello, playground"
var str = "Hello, playground"
print(str)

/** 可选 **/

var numString: String?

numString = "one"

let num: Int? = Int(numString!)

print(num ?? "num为nil")

//推荐写法
if let num = Int(numString ?? "") {
    print(num)
}

/** 元祖的使用 **/
func returnTwoValue() -> (Int, Int) {
    return (3, 5)
}

print(returnTwoValue())

/** 结构体 **/

struct myStruct {
    var myName: String
    var myAge: Int
}

let me = myStruct(myName: "小白", myAge: 5)
let me_two = me
print("\(me.myName) + \(me.myAge)")
//内存地址打印
print(Unmanaged<AnyObject>.passUnretained(me as AnyObject).toOpaque())
print(Unmanaged<AnyObject>.passUnretained(me_two as AnyObject).toOpaque())


/** 闭包的使用 要求打印一句话，在这句话末尾加上 “1234”  **/

func useTheClosure(closure: (String)->()) {
    closure("OneTwoThree")
}
//方式一
var myClosure = {
    (input: String) in
    print("\(input)" + "1234")
}
useTheClosure(closure: myClosure)

//方式二
useTheClosure(closure: {(str: String) in
    print("\(str)" + "1234")
})

//方式三
useTheClosure {
    print("\($0)" + "1234")
}
