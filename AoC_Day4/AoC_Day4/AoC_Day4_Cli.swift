//
//  AoC_Day4_Cli.swift
//  AoC_Day4
//
//  Created by Pieter Nijs on 04/12/2024.
//

import Foundation
import ArgumentParser
import RegexBuilder

@main
struct AoC_Day4_Cli: ParsableCommand {
    @Option(help: "Specify the path to the file containing the data")
    public var path: String
    
    public func run() throws {
        //Load the data
        let data = try loadData()
        
        doPuzzleOne(data: data)
        doPuzzleTwo(data: data)
    }
    
    private func doPuzzleTwo(data:[[Character]]){
        var result = 0
        
        let numberOfRows = data.count
        let numberOfColumns = data.first?.count ?? 0
  
        for row in 1..<numberOfRows-1 {
            for col in 1..<numberOfColumns-1 {
                if (data[row])[col] == "A" {
                    let word1 = "\(data[row-1][col-1])A\(data[row+1][col+1])"
                    let word2 = "\(data[row+1][col-1])A\(data[row-1][col+1])"
                    
                    if((word1 == "MAS" || word1 == "SAM") && (word2 == "MAS" || word2 == "SAM")) {
                        result += 1
                    }
                }
            }
        }
        
        print(result)
    }
    
    private func doPuzzleOne(data:[[Character]]){
        var result = 0
        
        let numberOfRows = data.count
        let numberOfColumns = data.first?.count ?? 0
        
        // Directions for checking the word "XMAS"
        let directions = [
            (0, 1),   // Right
            (0, -1),  // Left
            (1, 0),   // Down
            (-1, 0),  // Up
            (1, 1),   // Down-Right
            (1, -1),  // Down-Left
            (-1, 1),  // Up-Right
            (-1, -1)  // Up-Left
        ]
        
        for row in 0..<numberOfRows {
            for col in 0..<numberOfColumns {
                if data[row][col] == "X" {
                    for direction in directions {
                        if checkXmas(data: data, fromRow: row, col: col, direction: direction) {
                           result += 1
                        }
                    }
                }
            }
        }
        print(result)
    }
    
    private func checkXmas(data: [[Character]], fromRow row: Int, col: Int, direction: (Int, Int)) -> Bool {
        let numberOfRows = data.count
        let numberOfColumns = data.first?.count ?? 0
        let word = "XMAS"
        for i in 0..<word.count {
            let newRow = row + i * direction.0
            let newCol = col + i * direction.1
            if newRow < 0 || newRow >= numberOfRows || newCol < 0 || newCol >= numberOfColumns {
                return false
            }
            if data[newRow][newCol] != Array(word)[i] {
                return false
            }
        }
        return true
    }
    
    private func loadData() throws -> [[Character]] {
        let fileContents = try String(contentsOfFile: path, encoding: .utf8);
        
        return fileContents.split(separator: "\n").map { Array($0) }
    }
}
