//
//  Vector.swift
//  Numerical Methods 1
//
//  Created by Глеб Капустин on 17.10.2023.
//

import Foundation

enum Conditionality{
    case good
    case bad
}

enum Dimension {
    case little
    case big
}


final class Vector {
    private static let fileManager = FileManager.default
    
    
    private var size: Int
    private var elements: [Double]
    
    init(size: Int) {
        if size <= 0 {
            fatalError("Vector size must be greater than zero")
        }
        self.size = size
        elements = Array(repeating: 0.0, count: size)
    }
    
    convenience init(size: Int, minValue: Double, maxValue: Double) {
        self.init(size: size)

        elements = (0..<size).map { _ in
            minValue + Double(arc4random_uniform(UInt32(maxValue - minValue)))
        }
    }
    
    //Обусловленные векторы
    convenience init(size: Int, minValue: Double, maxValue: Double,con: Conditionality) {
        self.init(size: size)
        
        switch con {
        case .good:
            elements = (0..<size).map { _ in
                minValue + Double(arc4random_uniform(UInt32(maxValue - minValue)))
            }
        case .bad:
            elements = (0..<size).map { _ in
                minValue / 2 + Double(arc4random_uniform(UInt32(maxValue - minValue) / 2))
            }
        }
    }
    
    //векторы p и q в зависимости от размерности
    convenience init(size: Int, dim: Dimension) {
        self.init(size: size)
        
        switch dim {
        case .little:
            self.elements = (0..<size).map { _ in
                Double.random(in: 1...10)
            }
        case .big:
            self.elements = (0..<size).map { _ in
                Double.random(in: 1...1000)
            }
        }
    }
    
    convenience init(other: Vector) {
        self.init(size: other.size)
        self.elements = other.elements
    }
    
   
    static func + (left: Vector, right: Vector) -> Vector {
        if left.size != right.size {
            fatalError("Vectors must have the same size for addition")
        }
        
        let resultVector = Vector(size: left.size)
        
        for i in 1...left.size {
            resultVector[i] = left[i] + right[i]
        }
        return resultVector
    }
    
    static func - (left: Vector, right: Vector) -> Vector {
        if left.size != right.size {
            fatalError("Vectors must have the same size for subtraction")
        }
        
        let resultVector = Vector(size: left.size)
        
        for i in 1...left.size {
            resultVector[i] = left[i] - right[i]
        }
        return resultVector
    }
    
    static func * (left: Vector, right: Vector) -> Double {
        if left.size != right.size {
            fatalError("Vectors must have the same size for scalar product")
        }
        var result = 0.0
        for i in 1...left.size {
            result += left[i] * right[i]
        }
        
        return result
    }
   
    func getSize() -> Int {
        return size
    }
    
    func norm() -> Double {
        return elements.reduce(0) { max(abs($0), abs($1)) }
    }
    
    func printVector() {
        print(self.elements)
    }
    
    //Leave as is
    func save(toFile fileName: String) {

            // Get the current directory URL
        if let documentsPath = Vector.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filePath = documentsPath.appendingPathComponent(fileName)

                // Convert the vector to a string
                let vectorString = elements.map { String($0) }.joined(separator: " ")

                do {
                    // Write the vector data to the file
                    try vectorString.write(to: filePath, atomically: true, encoding: .utf8)
                    print("Vector saved to file: \(filePath.path)")
                } catch {
                    print("Error saving vector to file:", error)
                }
            } else {
                print("Could not access the documents directory.")
            }
    }
    
    //Leave as is
    static func load(fromFile fileName: String) -> Vector? {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("File not found in bundle: \(fileName)")
            return nil
        }
        
        let filePath = documentsPath.appendingPathComponent(fileName)
        do {
            let vectorString = try String(contentsOf: filePath, encoding: .utf8)
            let elements = vectorString.components(separatedBy: " ").compactMap { Double($0) }
            
            let vector = Vector(size: elements.count)
            vector.elements = elements
            return vector
        } catch {
            print("Error loading vector from file: \(error)")
            return nil
        }
    }
   
    
    //Leave as is
    func readFromScreen() {
        print("Enter all \(self.size) values for the vector on one line separated by spaces:")
        if let input = readLine() {
            let values = input.components(separatedBy: " ")
            if values.count == self.size {
                for (index, valueString) in values.enumerated() {
                    if let value = Double(valueString) {
                        self[index + 1] = value
                    } else {
                        print("Invalid input. Please enter valid numbers separated by spaces.")
                        return
                    }
                }
            } else {
                print("Invalid input. Please enter exactly \(self.size) values separated by spaces.")
            }
        } else {
            print("No input received.")
        }
    }
    
    //Leave as is
    private func fillWithRandomNumbers(from lowerBound: Double, to upperBound: Double) {
        self.elements = (0..<size).map { _ in Double.random(in: lowerBound...upperBound) }
    }
}


//Leave as is
extension Vector {
    subscript (index: Int) -> Double {
        get {
            guard index >= 1 && index <= size else {
                fatalError("Index out of bounds")
            }
            return elements[index - 1]
        }
        set {
            guard index >= 1 && index <= size else {
                fatalError("Index out of bounds")
            }
            elements[index - 1] = newValue
        }
    }
}
