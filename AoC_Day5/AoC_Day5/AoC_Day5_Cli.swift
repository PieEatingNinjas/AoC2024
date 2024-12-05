//
//  AoC_Day5_Cli.swift
//  AoC_Day5
//
//  Created by Pieter Nijs on 05/12/2024.
//

import Foundation
import ArgumentParser
import RegexBuilder

@main
struct AoC_Day5_Cli: ParsableCommand {
    @Option(help: "Specify the path to the file containing the data")
    public var path: String
    
    public func run() throws {
        //Load the data
        let data = try loadData()
        
        doPuzzleOne(orderRules: data.0, updates:  data.1)
        doPuzzleTwo(orderRules: data.0, updates:  data.1)
    }
    
    private func doPuzzleTwo(orderRules: [(Int, Int)], updates: [[Int]]){
        var invalidUpdates = [[Int]]()
        var sumOfMiddles = Int()
        
        
        for update in updates {
            let isValid = isUpdateValid(update: update, orderRules: orderRules)
            
            if(!isValid){
                invalidUpdates.append(update)
            }
        }
        
        for invalidUpdate in invalidUpdates{
            let valid = correctUpdate(update: invalidUpdate, orderRules: orderRules)
            print(valid)
            sumOfMiddles += valid[Int(valid.count / 2)]
        }
        
        print(sumOfMiddles)
    }
    
    private func doPuzzleOne(orderRules: [(Int, Int)], updates: [[Int]]){
        var validUpdates = [[Int]]()
        var sumOfMiddles = Int()
        
        
        for update in updates {
            let isValid = isUpdateValid(update: update, orderRules: orderRules)
            
            if(isValid){
                validUpdates.append(update)
            }
        }
        
        for validUpdate in validUpdates{
            sumOfMiddles += validUpdate[Int(validUpdate.count / 2)]
        }
        
        print(sumOfMiddles)
    }
    
    private func isUpdateValid(update:[Int], orderRules: [(Int, Int)]) -> Bool {
        for rule in orderRules {
            if(update.contains(rule.0) && update.contains(rule.1)){
                let index0 = update.firstIndex(of: rule.0)! //1
                let index1 = update.firstIndex(of: rule.1)! //0
                
                if(index1 - index0 < 0){
                    return false
                }
            }
        }
        
        return true
    }

    private func correctUpdate(update:[Int], orderRules: [(Int, Int)]) -> [Int] {
        var applicableRules = [(Int, Int)]()
        var weightDict = [Int: Int]()
        
        for rule in orderRules {
            if update.contains(rule.0) && update.contains(rule.1) {
                applicableRules.append(rule)
            }
        }
        
        for (_, element) in update.enumerated() {
            weightDict[element] = 0
        }
        
        var changed = true
        while changed {
            changed = false
            for (a, b) in applicableRules {
                if let weightA = weightDict[a], let weightB = weightDict[b], weightA >= weightB {
                    weightDict[b] = weightA + 1
                    changed = true
                }
            }
        }
        
        return update.sorted { (weightDict[$0] ?? Int.max) < (weightDict[$1] ?? Int.max) }
    }
  
    private func loadData() throws -> ([(Int, Int)], [[Int]]) {
        let fileContents = try String(contentsOfFile: path, encoding: .utf8);
        
        let splitData = fileContents.split(separator: "\n\n")
        
        let orderRules = splitData[0].split(separator: "\n").map { (Int($0.split(separator: "|")[0])!, Int($0.split(separator: "|")[1])!)  }
        
        let updates = splitData[1].split(separator: "\n").map { $0.split(separator: ",").map { Int($0)! } }
        
        return (orderRules, updates)
    }
}
