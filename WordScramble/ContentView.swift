//
//  ContentView.swift
//  WordScramble
//
//  Created by David Bailey on 25/05/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField(
                    "Enter your word", text: $newWord, onCommit: addNewWord
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()

                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
        }
    }

    func addNewWord() {
        let answer = newWord
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else {
            return
        }

        // @TODO: extra validation

        usedWords.insert(answer, at: 0)
        newWord = ""
    }

    func startGame() {
        guard let startWordsURL = Bundle.main.url(
            forResource: "start", withExtension: "txt"
        ) else {
            fatalError("Failed to get resource URL")
        }

        guard let startWords = try? String(contentsOf: startWordsURL) else {
            fatalError("Failed to construct string from resource")
        }

        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement()!
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
