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

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var score: Int {
        usedWords
            .map { word in word.count }
            .reduce(0) { x, y in x + y }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField(
                    "Enter your word", text: $newWord, onCommit: addNewWord
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()

                List(usedWords, id: \.self) {
                    Text($0)
                    Spacer()
                    Image(systemName: "\($0.count).circle")
                }
                .listStyle(GroupedListStyle())
            }
            .navigationTitle(rootWord)
            .navigationBarItems(
                leading: Text("Score: \(score)"),
                trailing: Button("Restart") {
                    startGame()
                    usedWords = []
                }
            )
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage))
            }
        }
    }

    func addNewWord() {
        let answer = newWord
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else {
            return
        }

        guard !usedWords.contains(answer) else {
            return showError(
                title: "Word used already",
                message: "Try something new!"
            )
        }

        guard rootWord.lowercased().contains(answer) else {
            return showError(
                title: "Word not valid",
                message: "\"\(answer)\" isn't inside \"\(rootWord)\""
            )
        }

        guard isReal(word: answer) else {
            return showError(
                title: "Word not valid",
                message: "\"\(answer)\" isn't a valid English word"
            )
        }

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

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)

        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word, range: range, startingAt: 0, wrap: false, language: "en"
        )
        return misspelledRange.location == NSNotFound
    }

    func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
