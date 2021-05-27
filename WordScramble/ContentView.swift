//
//  ContentView.swift
//  WordScramble
//
//  Created by David Bailey on 25/05/2021.
//

import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    var title: Text
    var message: Text
    var buttons: (Alert.Button, Alert.Button)?
}

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var alertItem: AlertItem?

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

                WordList(words: usedWords)
                    .listStyle(GroupedListStyle())
            }
            .navigationTitle(rootWord)
            .navigationBarItems(
                leading: Text("Score: \(score)"),
                trailing: Button("Restart", action: promptRestart)
            )
            .onAppear(perform: startGame)
            .alert(item: $alertItem, content: createAlert)
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
            return alertItem = AlertItem(
                title: Text("Word used already"),
                message: Text("Try something new!")
            )
        }

        guard rootWord != answer else {
            return alertItem = AlertItem(
                title: Text("Word not allowed"),
                message: Text("You can't use the same word")
            )
        }

        guard answer.count > 2 else {
            return alertItem = AlertItem(
                title: Text("Word too short"),
                message: Text("Use at least 3 characters")
            )
        }

        guard rootWord.lowercased().contains(answer) else {
            return alertItem = AlertItem(
                title: Text("Word not valid"),
                message: Text("\"\(answer)\" isn't inside \"\(rootWord)\"")
            )
        }

        guard isReal(word: answer) else {
            return alertItem = AlertItem(
                title: Text("Word not valid"),
                message: Text("\"\(answer)\" isn't a valid English word")
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

    func promptRestart() {
        alertItem = AlertItem(
            title: Text("Confirm restart"),
            message: Text("Would you like to restart the game?"),
            buttons: (
                .destructive(Text("Restart")) {
                    startGame()
                    usedWords = []
                    newWord = ""
                },
                .cancel()
            )
        )
    }

    func createAlert(_ alertItem: AlertItem) -> Alert {
        if let (primaryButton, secondaryButton) = alertItem.buttons {
            return Alert(
                title: alertItem.title,
                message: alertItem.message,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        } else {
            return Alert(
                title: alertItem.title,
                message: alertItem.message
            )
        }
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)

        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word, range: range, startingAt: 0, wrap: false, language: "en"
        )
        return misspelledRange.location == NSNotFound
    }
}

struct WordList: View {
    var words: [String]

    var wordsByScore: [Int: [String]] {
        Dictionary(grouping: words, by: { $0.count })
    }

    var body: some View {
        List {
            ForEach(
                wordsByScore.keys.sorted().reversed(),
                id: \.self
            ) { score in
                Section(header: Text("\(score) letters")) {
                    ForEach(wordsByScore[score]!, id: \.self) { word in
                        HStack {
                            Text(word)
                            Spacer()
                            Image(systemName: "\(word.count).circle")
                                .accessibilityHidden(true)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
