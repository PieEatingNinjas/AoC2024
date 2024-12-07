//
//  main.swift
//  AoC_Day7_Cli
//
//  Created by Pieter Nijs on 07/12/2024.
//

import Foundation
import ArgumentParser
import RegexBuilder

@main
struct AoC_Day7_Cli: ParsableCommand {
    @Option(help: "Specify the path to the file containing the data")
    public var path: String
    
    public func run() throws {
        //Load the data
        let data = try loadData()
        
        doPuzzleOne(operations: data)
        doPuzzleTwo(operations: data)
    }
    
    private func doPuzzleTwo(operations: [Operation]){
        var result = 0
        let validOperations = processOperationsPuzzleTwo(operations)
        
        for operation in validOperations {
            result += operation.expectedResult
        }
        
        print(result)
    }
    
    private func doPuzzleOne(operations: [Operation]){
        var result = 0
        let validOperations = processOperationsPuzzleOne(operations)
        
        for operation in validOperations {
            result += operation.expectedResult
        }
        
        print(result)
    }
    
    
    func evaluateOperationPuzzleOne(_ operation: Operation) -> Bool {
        let numbers = operation.numbers
        let expectedResult = operation.expectedResult
        
        func evaluate(_ index: Int, _ currentResult: Int) -> Bool {
            if index == numbers.count {
                return currentResult == expectedResult
            }
            let addResult = evaluate(index + 1, currentResult + numbers[index])
            let multiplyResult = evaluate(index + 1, currentResult * numbers[index])
            return addResult || multiplyResult
        }
        
        return evaluate(1, numbers[0])
    }

    func processOperationsPuzzleOne(_ operations: [Operation]) -> [Operation] {
        var validOperations = [Operation]()
        for operation in operations {
            let result = evaluateOperationPuzzleOne(operation)
            
            if(result) {
                validOperations.append(operation)
            }
            
            print("Operation: \(operation.numbers) -> \(operation.expectedResult) = \(result)")
        }
        return validOperations
    }
    
    func evaluateOperationPuzzleTwo(_ operation: Operation) -> Bool {
        let numbers = operation.numbers
        let expectedResult = operation.expectedResult
        
        func evaluate(_ index: Int, _ currentResult: Int) -> Bool {
            if index == numbers.count {
                return currentResult == expectedResult
            }
            let addResult = evaluate(index + 1, currentResult + numbers[index])
            let multiplyResult = evaluate(index + 1, currentResult * numbers[index])
            let concatResult = evaluate(index + 1, Int("\(currentResult)\(numbers[index])") ?? 0)
            return addResult || multiplyResult || concatResult
        }
        
        return evaluate(1, numbers[0])
    }

    func processOperationsPuzzleTwo(_ operations: [Operation]) -> [Operation] {
        var validOperations = [Operation]()
        for operation in operations {
            let result = evaluateOperationPuzzleTwo(operation)
            
            if(result) {
                validOperations.append(operation)
            }
            
            print("Operation: \(operation.numbers) -> \(operation.expectedResult) = \(result)")
        }
        return validOperations
    }
    
    private func loadData() throws -> [Operation] {
        let fileContents = try String(contentsOfFile: path, encoding: .utf8);
        
        let splitData = fileContents.split(separator: "\n")
        
        return splitData.map { Operation(numbers: $0.split(separator: ":")[1].split(separator: " ").map({Int($0)!}), expectedResult:
                                            Int(String($0.split(separator: ":")[0]))!)}
    }
}

struct Operation {
    var numbers = [Int]()
    var expectedResult = 0
}
