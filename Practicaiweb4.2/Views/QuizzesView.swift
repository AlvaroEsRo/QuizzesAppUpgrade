//
//  QuizzesView.swift
//  P4.1_quizzes
//
//  Created by d074 DIT UPM on 14/11/24.
//

import SwiftUI

struct QuizzesView: View {
    @StateObject private var quizzesModel = QuizzesModel()  // Crear instancia de QuizzesModel
    @State private var quizzesAcertados : [QuizItem.ID] = []
    
    var body: some View {
        NavigationView{
            
            List(quizzesModel.quizzes) { quiz in  // Usamos quizzesModel.quizzes como fuente de datos
                NavigationLink(destination: QuizView(quizzesAcertados: $quizzesAcertados, quiz: quiz))
                {
                    RowView(quiz:quiz)
                }
            }
            .navigationTitle("Quizzes")
            .toolbar {
                // Añadir el contador al lado derecho del título
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Aciertos: \(quizzesAcertados.count)")  // Muestra el número de quizzes acertados
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
    
            .onAppear {
                quizzesModel.load()  // Cargar los quizzes cuando la vista aparece
            }
            // Título de la vista
        }
    }
}

#Preview {
    QuizzesView()
}
