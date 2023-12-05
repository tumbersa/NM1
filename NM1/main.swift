//
//  main.swift
//  First Command Line
//
//  Created by Глеб Капустин on 17.10.2023.
//

import Foundation


func answerCheck(b: Conditionality, pq: Dimension){
    print(String(format: "%@", "Size") + "   Error")
    
    var size = 8
    while size < 4097 {
        print(String(format: "%4d", size), terminator: "   ")
    
        let a = Matrix(size: size, k: 5, b: b, pq: pq)
        var x_exact = Vector(size: size, minValue: 10, maxValue: 20)
        var f = Vector(size: size)
        
        f = a * x_exact
        
        var x = Vector(size: size)
        x = a.solveSystem(f: f, x: &x_exact)
        
        print(String(format: "%12.5e", (x_exact - x).norm()), terminator: "\n")
        
        size *= 2
    }
    print()
}

print("Conditionality b: good, dimension pq: little")
answerCheck(b: .good, pq: .little)

print("Conditionality b: good, dimension pq: big")
answerCheck(b: .good, pq: .big)

print("Conditionality b: bad, dimension pq: little")
answerCheck(b: .bad, pq: .little)

print("Conditionality b: bad, dimension pq: big")
answerCheck(b: .bad, pq: .big)
