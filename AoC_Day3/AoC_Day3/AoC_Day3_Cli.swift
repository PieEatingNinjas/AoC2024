//
//  AoC_Day3_Cli.swift
//  AoC_Day3
//
//  Created by Pieter Nijs on 03/12/2024.
//

import Foundation
import ArgumentParser
import RegexBuilder

@main
struct AoC_Day3_Cli: ParsableCommand {
    @Option(help: "Specify the path to the file containing the data")
    public var path: String
    
    public func run() throws {
        //Load the data
        let data = try loadData()
        
        doPuzzleOne(data: data)
        doPuzzleTwo(data: data)
    }
    
    private func doPuzzleOne(data:String){
        var result = 0
        let mulData = getMulsData(data: data)
        
        for numbers in mulData {
            result += doMul(number1: numbers.0, number2: numbers.1)
        }
        
        print(result)
    }
    
    private func doPuzzleTwo(data:String){
        var result = 0
        let strippedData = removeInstructions(text: data)
        let mulData = getMulsData(data: strippedData)
        
        for numbers in mulData {
            result += doMul(number1: numbers.0, number2: numbers.1)
        }
        
        print(result)
    }

    func removeInstructions(text: String) -> String {
        // Replace "don't()" and "do()" with unique markers
        let cleanText = text
            .replacingOccurrences(of: "don't()", with: "$$$$don't()")
            .replacingOccurrences(of: "do()", with: "$$$$do()")
        
        // Split the text based on the unique markers
        let split = cleanText.split(separator: "$$$$", omittingEmptySubsequences: true)
        
        // Filter out the segments that contain "don't()"
        let lines = split.filter { !$0.contains("don't()") }
        
        // Join the remaining segments
        return lines.joined()
    }
    
    private func getMulsData(data:String) -> [(Int, Int)] {
        let regex = Regex {
            "mul("
            Capture {
                OneOrMore(.digit)
            }
            ","
            Capture {
                OneOrMore(.digit)
            }
            ")"
        }
        
        return data.matches(of: regex).map { (Int($0.1)!, Int($0.2)!) }
    }
    
    private func doMul(number1:Int, number2:Int) -> Int {
        return number1 * number2
    }
    
    private func loadData() throws -> String {
        return try String(contentsOfFile: path, encoding: .utf8);
    }
}
