//
//  AoC_Day1_Cli.swift
//  AoC_Day1
//
//  Created by Pieter Nijs on 02/12/2024.
//

import Foundation
import ArgumentParser

@main
struct AoC_Day1_Cli: ParsableCommand {
    @Option(help: "Specify the path to the file containing the lists")
    public var path: String

    public func run() throws {
        //Load the lists
        let (leftList, rightList) = try loadLists()
      
        doPuzzleOne(leftList: leftList, rightList: rightList)
      
        doPuzzleTwo(leftList: leftList, rightList: rightList)
    }
    
    private func doPuzzleOne(leftList: [Int], rightList:[Int]) {
        //For keeping total distance
        var totalDistance = Int()
        
        //Sort the lists
        let sortedLeft = leftList.sorted()
        let sortedRight = rightList.sorted()
        
        //Loop over list
        for (elementLeft, elementRight) in zip(sortedLeft, sortedRight) {
            // Calculate distance between elements and add to totalDistance
            totalDistance += abs(elementLeft - elementRight)
        }
        
        print("Total distance: \(totalDistance)")
    }
    
    private func doPuzzleTwo(leftList: [Int], rightList:[Int]) {
        //For keeping the similarity score
        var similarity = Int()
        //Loop over list
        for elementLeft in leftList {
            // Count occurrences in right list
            let occurrences = rightList.filter { $0 == elementLeft }.count
            // Add to similarity
            similarity += (elementLeft * occurrences)
        }
        print("Similarity score: \(similarity)")
    }
    
    private func loadLists() throws -> ([Int], [Int]){
        var leftList = [Int]()
        var rightList = [Int]()
        
        let fileContents = try
            //Read file contents
            String(contentsOfFile: path, encoding: String.Encoding.utf8)
                //Split on newline, removing empty ones
                .split(separator: "\n", omittingEmptySubsequences: true)
        
        for line in fileContents {
            // Split every line on space, removing empty subsequences
            let split = line.split(separator: " ", omittingEmptySubsequences: true)
                        
            if let leftValue = Int(split[0]), let rightValue = Int(split[1]) {
                leftList.append(leftValue)
                rightList.append(rightValue)
            }
        }
        
        return (leftList, rightList)
    }
}
