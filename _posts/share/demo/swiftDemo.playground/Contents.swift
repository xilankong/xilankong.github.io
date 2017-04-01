//: Playground - noun: a place where people can play

import UIKit
import Foundation

//swift基础

//变量的定义、使用  关键字 ： 强类型
let million = 1_000_000

let fifteen_10 = 15
let fifteen_16 = 0xF
let fifteen_8 = 0o17
let fifteen_2 = 0b1111

var PI = 314e-2

type(of:PI)
type(of:fifteen_10)

PI = 15 + 314e-2
type(of:PI)

//let PI_fifteen = PI + fifteen_10
let PI_fifteen = PI + Double(fifteen_10) //这里实际是重新生成了一个Double类型的值，并非类型转换



//结构体的定义 关键字 :
struct myStruct {
    var myName: String
    var myAge: Int
    
    init? (){
        myName = "结构体"
        myAge = 2
    }
}

let struct_me = myStruct()
let struct_me_copy = struct_me
print("\(struct_me?.myName) + \(struct_me?.myAge)")
//内存地址打印
print(Unmanaged<AnyObject>.passUnretained(struct_me as AnyObject).toOpaque())
print(Unmanaged<AnyObject>.passUnretained(struct_me_copy as AnyObject).toOpaque())


//类的定义 关键字
class myClass {
    var myName: String
    
    init () {
        myName = "类"
    }
    
    //方法的定义
    func myFunction() -> Int {
        return 5
    }
}

let class_me = myClass()
print(class_me.myName)
let class_me_copy = class_me
//内存地址打印
print(Unmanaged<AnyObject>.passUnretained(class_me as AnyObject).toOpaque())
print(Unmanaged<AnyObject>.passUnretained(class_me_copy as AnyObject).toOpaque())


//可选值
var numString: String?

numString = "one"

let num: Int? = Int(numString!)

print(num ?? "num为nil")

//推荐写法
//不处理为空字符串
func unPackFunc(numString: String?) {
    guard let numStr = numString, let num = Int(numStr) else {
        return
    }
    print(num)
}
//处理为空字符串
if let num = Int(numString ?? "") {
    print(num)
}



//元祖的使用
func returnTwoValue() -> (String, Int, String) {
    return ("couple", 5, "2014年")
}

print(returnTwoValue().0)


//闭包的使用 要求打印一句话，在这句话末尾加上 “1234”

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


//协议的定义与使用 和java 接口一样 可以多实现

protocol Drawable {
    var lineWidth: Double {get set}
    func draw()
}
protocol fillColor: class {
    var color: String {get set}
    func fill()
}
extension Drawable {
    func draw() {
        print("default draw")
    }
}

struct Line: Drawable {
    private var _lineWidth: Double?
    internal var lineWidth: Double {
        get{
           return _lineWidth ?? 1
        }
        set(newValue){
            _lineWidth = newValue
        }
    }
    internal func draw() {
        print("\(self) draw Line width : \(lineWidth)")
    }

}

class Cycle: Drawable,fillColor {

    private var _color: String?
    internal var color: String {
        get{
            return _color ?? "black"
        }
        set(newValue){
            _color = newValue
        }
    }

    private var _lineWidth: Double?
    internal var lineWidth: Double {
        get{
            return _lineWidth ?? 2
        }
        set(newValue){
            _lineWidth = newValue
        }
    }
    
    internal func draw() {
        print("\(self) draw Cycle width : \(lineWidth)")
    }
    
    internal func fill() {
        print("\(self) fill Cycle with \(color) color")
    }
}
Line().draw()
Cycle().draw()
Cycle().fill()