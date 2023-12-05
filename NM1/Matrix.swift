//
//  Matrix.swift
//  Numerical Methods 1
//
//  Created by Глеб Капустин on 17.10.2023.
//

import Foundation

final class Matrix {
    private var a: Vector
    private var b: Vector
    private var c: Vector
    private var p: Vector
    private var q: Vector
    
    private let size: Int
    let (k,l):(Int,Int)
    
    init(size: Int,k: Int, b: Conditionality = .good, pq: Dimension = .little){
        if size <= 0 {
            fatalError("Matrix size must be greater than zero")
        }
        if k < 0 || k + 2 == size {
            fatalError("Invalid argument of k. It should be in the range 0...\(size - 3)")
        }
        
        self.size = size
        self.a = Vector(size: size, minValue: 20, maxValue: 40)
        self.b = Vector(size: size, minValue: 20, maxValue: 40, con: b)
        self.c = Vector(size: size, minValue: 20, maxValue: 40)
        self.p = Vector(size: size, dim: pq)
        self.q = Vector(size: size, dim: pq)
        self.k = k
        self.l = k + 2
    }
    
    func getNumRows() -> Int{
        return size
    }
    
    static func + (left: Matrix, right: Matrix) -> Matrix{
        if left.size != right.size || left.k != right.k {
            fatalError("Matrices must have the same size and k for addition")
        }
        
        let resultMatrix = Matrix(size: left.size, k: left.k)
        resultMatrix.a = left.a + left.a
        resultMatrix.b = left.b + left.b
        resultMatrix.c = left.c + left.c
        resultMatrix.p = left.p + left.p
        resultMatrix.q = left.q + left.q
        
        return resultMatrix
    }
    
    static func - (left: Matrix, right: Matrix) -> Matrix{
        if left.size != right.size || left.k != right.k {
            fatalError("Matrices must have the same size and k for subtraction")
        }
        
        let resultMatrix = Matrix(size: left.size, k: left.k)
        resultMatrix.a = left.a - left.a
        resultMatrix.b = left.b - left.b
        resultMatrix.c = left.c - left.c
        resultMatrix.p = left.p - left.p
        resultMatrix.q = left.q - left.q
        
        return resultMatrix
    }
    
    static func * (left: Matrix, right: Vector) -> Vector{
        if left.size != right.getSize() {
            fatalError("Matrix and vector dimensions are not compatible for multiplication")
        }
        
        let resultVector = Vector(size: left.size)
        
        for i in 1...left.size{
            for j in 1...left.size{
                switch j {
                case i:
                    resultVector[i] = resultVector[i] + left.b[i] * right[j]
                case i - 1:
                    resultVector[i] = resultVector[i] + left.a[i] * right[j]
                case i + 1:
                    resultVector[i] = resultVector[i] + left.c[i] * right[j]
                case left.k:
                    resultVector[i] = resultVector[i] + left.p[i] * right[j]
                case left.l:
                    resultVector[i] = resultVector[i] + left.q[i] * right[j]
                default: break
                }
            }
        }
        
        return resultVector
    }
    
    func printMatrix(){
        for i in 1...size{
            for j in 1...size{
                switch j {
                case i:
                    print(String(format: "%9.5f", b[i]), terminator: "")
                case i - 1:
                    print(String(format: "%9.5f", a[i]), terminator: "")
                case i + 1:
                    print(String(format: "%9.5f", c[i]), terminator: "")
                case k:
                    print(String(format: "%9.5f", p[i]), terminator: "")
                case l:
                    print(String(format: "%9.5f", q[i]), terminator: "")
                default:
                    print(String(format: "%9d", 0), terminator: "")
                }
            }
            print("\n\n")
        }
        print("\n")
    }
    
    func printVectors(){
        print("a: ",terminator: "")
        a.printVector()
        print("b: ",terminator: "")
        b.printVector()
        print("c: ",terminator: "")
        c.printVector()
        print("p: ",terminator: "")
        p.printVector()
        print("q: ",terminator: "")
        q.printVector()
    }
    
    
    
    func save(toFile fileName: String){
        let fileURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
        var matrixString: String = ""
        for i in 1...size {
            var elements:[Double] = Array(repeating: 0, count: 14)
            elements[k-1] = p[i]
            elements[l-1] = q[i]
            elements[i-1] = b[i]
            if i != size {
                elements[i] = c[i]
            }
            if i != 1 {
                elements[i - 2] = a[i]
            }
            matrixString += elements.map{String($0)}.joined(separator: " ") + "\n"
        }
        
        do {
            try matrixString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving matrix to file: \(error)")
        }
    }
    
    static func load(fromFile filename: String,k: Int) -> Matrix? {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: nil) else {
            Swift.print("File not found in bundle: \(filename)")
            return nil
        }
        
        do {
            let matrixString = try String(contentsOf: fileURL, encoding: .utf8)
            let array = matrixString.components(separatedBy: "\n")
            var j = 1
            let (a,b,c,p,q) = (Vector(size: array.count),Vector(size: array.count),Vector(size: array.count),Vector(size: array.count),Vector(size: array.count))
            for i in array {
                if j != array.count + 1 {
                    let elements = i.components(separatedBy: " ").compactMap { Double(String($0))}
                    b[j] = elements[j - 1]
                    if j != array.count {
                        c[j] = elements[j]
                    }
                    p[j] = elements[k - 1]
                    q[j] = elements[k + 1]
                    if j != 1{
                        a[j] = elements[j - 2]
                    }
                    j += 1
                }
            }
            let matrix = Matrix(size: array.count, k: k)
            matrix.a = a
            matrix.b = b
            matrix.c = c
            matrix.p = p
            matrix.q = q
            return matrix
        } catch {
            Swift.print("Error loading vector from file: \(error)")
            return nil
        }
    }
    
    func readFromScreen(size: Int,k: Int) {
            print("Enter all \(size * size) values for the matrix on one line separated by spaces:")
            let (a,b,c,p,q) = (Vector(size: size),Vector(size: size),Vector(size: size),Vector(size: size),Vector(size: size))
            var flag = true
    
            var j = 1
            while flag {
    
                guard let input = readLine(strippingNewline: true) else {
                    fatalError("Wrong input")
                }
    
                if j != size + 1 {
                    let elements = input.components(separatedBy: " ").compactMap { Double(String($0))}
                    print()
                    print(elements)
                    print(input)
                    b[j] = elements[j - 1]
                    if j != size {
                        c[j] = elements[j]
                    }
                    p[j] = elements[k - 1]
                    q[j] = elements[k + 1]
                    if j != 1{
                        a[j] = elements[j - 2]
                    }
                    j += 1
                } else {
                    flag = false
                }
    
            }
            self.a = a
            self.b = b
            self.c = c
            self.p = p
            self.q = q
        }
    
    func adjointPrint(f: Vector){
        for i in 1...size {
            for j in 1...size {
                switch j {
                case i:
                    print(String(format: "%9.5f", b[i]), terminator: "")
                case i - 1:
                    print(String(format: "%9.5f", a[i]), terminator: "")
                case i + 1:
                    print(String(format: "%9.5f", c[i]), terminator: "")
                case k:
                    print(String(format: "%9.5f", p[i]), terminator: "")
                case l:
                    print(String(format: "%9.5f", q[i]), terminator: "")
                default:
                    print(String(format: "%9d", 0), terminator: "")
                }
            }
            print(String(format: "%9s", "|") + String(format: "%9.5f", f[i]))
            print("\n\n")
        }
        print("\n")
    }
    
    
    func solveSystem(f: Vector,x: inout Vector) -> Vector{
        var f = f
        var x1 = Vector(size: self.size)
        stage1(f: &f, x: x)
        stage2(f: &f, x: x)
        stage3_5(f: &f, x: x)
        stage6_7(f: &f, x: x)
        stage8_9(f: &f, x: &x1)
        return x1
    }
    
    
    func stage1(f: inout Vector, x: Vector){
        for i in 1..<k {
            var r: Double = 1 / b[i] //приводим b к 1
            b[i] = 1
            c[i] *= r
            p[i] *= r
            q[i] *= r
            f[i] *= r
            
            r = a[i + 1]
            a[i + 1] = 0
            b[i + 1] -= r * c[i]
            q[i + 1] -= r * q [i]
            f[i + 1] -= r * f[i]
            
            if i == k - 2{ // элемент под b к 0
                c[i + 1] -= r * p[i]//c
            } else {
                p[i + 1] -= r * p[i]//p
            }
        }
        
//        if size == 8 {
//            print("Iteration 1:")
//            adjointPrint(f: f)
//            print((f - self * x).norm())
//        }
    }
    func stage2(f: inout Vector, x: Vector){
        for i in ((l + 1)...size).reversed() {
            var r = 1 / b[i] //приводим b к 1
            a[i] *= r
            p[i] *= r
            q[i] *= r
            f[i] *= r
            
            r = c[i - 1]
            c[i - 1] = 0
            b[i - 1] -= r * a[i]
            p[i - 1] -= r * p[i]
            f[i - 1] -= r * f[i]
            
            if i == l + 2 {
                a[i - 1] -= r * q[i]//a
            } else {
                q[i - 1] -= r * q[i]//q
            }
        }
        //        if size == 8 {
        //            print("Iteration 2:")
        //            adjointPrint(f: f)
        //        }
    }
    func stage3_5(f: inout Vector, x: Vector){
        //stage 3
        var r = 1 / b[k + 1] //элемент в b в k + 1 к 1
        b[k + 1] = 1
        a[k + 1] *= r
        c[k + 1] *= r
        f[k + 1] *= r
        
        r = c[k] //элемент с в k к 0
        c[k] = 0
        b[k] -= r * a[k + 1]
        q[k] -= r * c[k + 1]
        f[k] -= r * f[k + 1]
        
        r = a[l] // элемент а в l к 0
        a[l] = 0
        b[l] -= r * c[k + 1]
        p[l] -= r * a[k + 1]
        f[l] -= r * f[k + 1]
        //        if size == 8 {
        //            print("Iteration 3:")
        //            adjointPrint(f: f)
        //            print((f - self * x).norm())
        //        }
        
        
        //stage 4
        r = 1 / b[k] // элемент b в k к 1
        b[k] = 1
        q[k] *= r
        f[k] *= r
        
        r = p[l] //элемент p в l к 0
        p[l] = 0
        b[l] -= r * q[k]
        f[l] -= r * f[k]
        
        r = 1 / b[l] //элемент b в l к 0
        b[l] = 1
        f[l] *= r
        
        r = q[k] //элемент q в k к 0
        q[k] = 0
        f[k] -= r * f[l]
        //        if size == 8 {
        //            print("Iteration 4:")
        //            adjointPrint(f: f)
        //        }
        
        //stage 5
        r = a[k + 1]//элемент a в k+1 к 0
        a[k + 1] = 0
        f[k + 1] -= r * f[k]
        //        if size == 8 {
        //            print("Iteration 5:")
        //            adjointPrint(f: f)
        //            print((f - self * x).norm())
        //        }
    }
    func stage6_7(f: inout Vector, x: Vector){
        //stage 6
        for i in (l + 1)...size {//зануляем элементы p и q от l + 1 до size
            var r = p[i] //обнуление p
            p[i] = 0
            f[i] -= r * f[k]
            
            if i != l + 1 {
                r = q[i] //обнуление q
                q[i] = 0
                f[i] -=  r * f[l]
            }
        }
        //        if size == 8 {
        //            print("Iteration 6:")
        //            adjointPrint(f: f)
        //        }
        
        //stage 7
        for i in 1..<k {//зануляем элементы p и q от 1 до k - 1
            var r: Double
            if i != k - 1 {
                r = p[i]//обнуление p
                p[i] = 0
                f[i] -= r * f[k]
            }
            
            r = q[i]//обнуление q
            q[i] = 0
            f[i] -= r * f[l]
        }
        //        if size == 8 {
        //            print("Iteration 7:")
        //            adjointPrint(f: f)
        //            print((f - self * x).norm())
        //        }
    }
    func stage8_9(f: inout Vector, x: inout Vector){
        x[l] = f[l] //получение x от 2 до l
        for i in (1...(l - 1)).reversed() {
            x[i] = f[i] - c[i] * x[i + 1]
        }
        
        for i in (l + 1)...size { //получение x от l + 1 до size
            x[i] = f[i] - a[i] * x[i - 1]
        }
    }
    
}
