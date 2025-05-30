//
//  ContentView.swift
//  Tugas
//
//  Created by Faidhil Hajairin on 23/12/21.
//

import SwiftUI

struct homeScreen: View {
    var body: some View {
        NavigationView{
            VStack{
            Text("Tickity Tac Toe")
                    .bold()
                    .offset(y: -100)
                    .font(.title)
                
                NavigationLink(destination: TicTacToe() , label:{ Text("Play")
                        .bold()
                        .frame(width: 150, height: 50)
                        .background(Color.gray.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(35)
                })
                
            }
        }
    }
}

enum SquareStatus {
    case empty
    case home
    case visitor
}

class Square : ObservableObject {
    @Published var squareStatus : SquareStatus
    
    init(status : SquareStatus){
        self.squareStatus = status
    }
}

class TicTacToeModel : ObservableObject {
    @Published var squares = [Square]()
    
    init() {
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }
    
    func resetGame() {
        for i in 0...8 {
            squares[i].squareStatus = .empty
        }
    }
    
    var gameOver : (SquareStatus, Bool) {
            get {
                if thereisAWinner != .empty {
                    return (thereisAWinner, true)
                } else {
                    for i in 0...8 {
                        if squares[i].squareStatus == .empty {
                            return(.empty, false)
                        }
                    }
                    return (.empty, true)
                }
            }
        }
    
    private var thereisAWinner: SquareStatus {
        get {
            if let check = self .checkIndexes([0, 1, 2]) {
                return check
            } else if let check = self .checkIndexes([3, 4, 5]){
                return check
            } else if let check = self .checkIndexes([6, 7, 8]){
                return check
            } else if let check = self .checkIndexes([0, 3, 6]){
                return check
            } else if let check = self .checkIndexes([1, 4, 7]){
                return check
            } else if let check = self .checkIndexes([2, 5, 8]){
                return check
            } else if let check = self .checkIndexes([0, 4, 8]){
                return check
            } else if let check = self .checkIndexes([2, 4, 6]){
                return check
            }
            return .empty
        }
    }
    
    private func checkIndexes(_ indexes : [Int]) -> SquareStatus? {
           var homeCounter : Int = 0
           var visitorCounter : Int = 0
           for index in indexes {
               let square = squares[index]
               if square.squareStatus == .home {
                   homeCounter += 1
               } else if square.squareStatus == .visitor {
                   visitorCounter += 1
               }
        }
        if homeCounter == 3 {
            return .home
        }else if visitorCounter == 3 {
            return .visitor
        }
        return nil
    }
    
    private func moveAI() {
            var index = Int.random(in: 0...8)
            while makeMove(index: index, player: .visitor) == false && gameOver.1 == false {
                index = Int.random(in: 0...8)
            }
        }
    
    func makeMove(index: Int, player: SquareStatus) -> Bool {
        if squares[index].squareStatus == .empty {
            squares[index].squareStatus = player
            if player == .home{
                moveAI()
            }
            return true
        }
        return false
    }
    
}

struct SquareView : View {
    @ObservedObject var dataSource : Square
    var action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
            
        }, label: {
            Text(self.dataSource.squareStatus == .home ? "X" : self.dataSource.squareStatus == .visitor ? "0" : " ")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .frame(width: 70, height: 70, alignment:.center)
                .background(Color.gray.opacity(0.3).cornerRadius(10))
                .padding(4)
        })
    }
}

struct TicTacToe: View {
    @StateObject var tictacToeModel = TicTacToeModel()
    @State var gameOver : Bool = false
    func buttonAction ( index : Int){
        _ = self.tictacToeModel.makeMove(index: index, player: .home)
        self.gameOver = self.tictacToeModel.gameOver.1
    }
    
    var body: some View {
        VStack {
            Text("Tickity Tac Toe")
                .bold()
                .foregroundColor(Color.black.opacity(0.7))
                .padding(.bottom)
                .font(.title2)
            ForEach(0 ..< tictacToeModel.squares.count / 3, content: {
                row in
                HStack {
                    ForEach(0 ..< 3, content: {
                        column in
                        let index = row * 3 + column
                        SquareView(dataSource: tictacToeModel.squares[index], action:{self.buttonAction(index: index)})
                    })
                }
            })
        }.alert(isPresented: self.$gameOver, content: {
            Alert(title: Text("Game Over"), message: Text(self.tictacToeModel.gameOver.0 != .empty ? self.tictacToeModel.gameOver.0 == .home ? "You Win": "COM Wins" : "Nobody Wins"), dismissButton: Alert.Button.destructive(Text("ok"), action:{
                self.tictacToeModel.resetGame()
            }))
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        homeScreen()
    }
}
