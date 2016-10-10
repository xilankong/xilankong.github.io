---
layout: post
category: 学习之路
title:  "Blocks For IOS" 
---

## 1.解决block中的循环引用

循环引用 — 当A对象里面强引用了B对象，B对象又强引用了A对象，这样两者的retainCount值一直都无法为0，于是内存始终无法释放，导致内存泄露。所谓的内存泄露就是本应该释放的对象，在其生命周期结束之后依旧存在。

当然也存在自身引用自身的，当一个对象内部的一个obj，强引用的自身，也会导致循环引用的问题出现。常见的就是block里面引用的问题。

http://ios.jobbole.com/88708/



http://ios.jobbole.com/88676/



http://www.jianshu.com/p/f9956b102d36