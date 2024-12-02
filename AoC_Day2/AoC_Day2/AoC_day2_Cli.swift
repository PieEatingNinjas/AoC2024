//
//  AoC_Day2_Cli.swift
//  AoC_Day2
//
//  Created by Pieter Nijs on 02/12/2024.
//

import Foundation
import ArgumentParser

@main
struct AoC_Day2_Cli: ParsableCommand {
    @Option(help: "Specify the path to the file containing the list")
    public var path: String
    
    public func run() throws {
        //Load the list
        let list = try loadList()
        
        doPuzzleOne(reports: list)
        
        doPuzzleTwo(reports: list)
    }
    
    private func doPuzzleTwo(reports:[[Int]]){
        var countSafeReports = 0
        
        for report in reports {
            let (result, _) = isReportSafeWithOneToleranceLevel(report: report)
            
            if (result){
                print("report \(report) is SAFE!")
                countSafeReports += 1
            }
            else{
                print("report \(report) is UNSAFE!")
            }
        }
        print("Total Safe Reports: \(countSafeReports)")
    }
    
    private func doPuzzleOne(reports:[[Int]]){
        var countSafeReports = 0
        
        for report in reports {
            let result = isReportSafe(report: report)
            
            if (result){
                print("report \(report) is SAFE!")
                countSafeReports += 1
            }
            else{
                print("report \(report) is UNSAFE!")
            }
        }
    }
    
    private func isReportSafe(report:[Int]) -> Bool {
        var isReportSafe:Bool = true
        var isReportDescending : Bool?
        
        for (index, element) in report.enumerated() {
            let nextElementIndex = index + 1;
            if(nextElementIndex < report.count){
                let nextElement = report[nextElementIndex]
                
                if(nextElement == element){
                    isReportSafe = false;
                    break
                }
                
                let diff = element - nextElement;
                let isDescending = diff > 0
                
                if(abs(diff) > 3){
                    isReportSafe = false
                    break
                }
                else if(isReportDescending == nil){
                    isReportDescending = isDescending
                }
                else if(isReportDescending != isDescending) {
                    isReportSafe = false;
                    break
                }
            }
        }
        return isReportSafe
    }
    
    private func isReportSafeWithOneToleranceLevel(report: [Int]) -> (Bool, Int?) {
        let (isReportSafe, faultLevel) = isReportSafeWithFaultLevel(report: report)
        
        if isReportSafe || faultLevel == nil {
            return (isReportSafe, faultLevel)
        }
        
        return checkReport(report: report, faultLevel: faultLevel!)
    }
    
    private func checkReport(report: [Int], faultLevel: Int) -> (Bool, Int?) {
        let indicesToCheck = [faultLevel, faultLevel - 1, faultLevel + 1]
        
        for index in indicesToCheck {
            if index >= 0 && index < report.count {
                var modifiedReport = report
                modifiedReport.remove(at: index)
                let (isReportSafe, _) = isReportSafeWithFaultLevel(report: modifiedReport)
                if isReportSafe {
                    return (true, index)
                }
            }
        }
        
        return (false, faultLevel)
    }
    
    private func isReportSafeWithFaultLevel(report: [Int]) -> (Bool, Int?) {
        var isReportSafe = true
        var isReportDescending: Bool?
        var faultLevel: Int? = nil
        
        for (index, element) in report.enumerated() {
            let nextElementIndex = index + 1
            if nextElementIndex < report.count {
                let nextElement = report[nextElementIndex]
                
                if nextElement == element {
                    isReportSafe = false
                    faultLevel = index
                    break
                }
                
                let diff = element - nextElement
                let isDescending = diff > 0
                
                if abs(diff) > 3 {
                    isReportSafe = false
                    faultLevel = index
                    break
                } else if isReportDescending == nil {
                    isReportDescending = isDescending
                } else if isReportDescending != isDescending {
                    isReportSafe = false
                    faultLevel = index
                    break
                }
            }
        }
        
        return (isReportSafe, faultLevel)
    }
    
    private func loadList() throws -> [[Int]] {
        var list = [[Int]]()
        let fileContents = try String(contentsOfFile: path, encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: true)
        
        for line in fileContents {
            let split = line.split(separator: " ", omittingEmptySubsequences: true).map { Int($0)! }
            list.append(split)
        }
        
        return list
    }
}
