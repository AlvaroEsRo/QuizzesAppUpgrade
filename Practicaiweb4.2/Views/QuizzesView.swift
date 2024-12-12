import SwiftUI

struct QuizzesView: View {
    @StateObject private var quizzesModel = QuizzesModel()  // Crear instancia de QuizzesModel
    @State private var quizzesAcertados: [QuizItem.ID] = []  // Mantener los quizzes acertados
    @State private var showQuizzesPendientes: Bool = true  // Opción seleccionada en el Toggle
    
    var body: some View {
        NavigationView {
            VStack {
                
                
                // Toggle para elegir entre Mostrar Todos o Mostrar No Acertados
                Toggle("Mostrar Quizzes Pendientes", isOn: $showQuizzesPendientes)
                    .padding([.top, .horizontal])
                
                // Filtrar los quizzes según la opción seleccionada
                List(filteredQuizzes) { quiz in
                    NavigationLink(destination: QuizView(quizzesAcertados: $quizzesAcertados, quiz: quiz).environmentObject(quizzesModel)) {
                        RowView(quiz: quiz)
                    }
                }
                .background(Color.clear)
                .navigationTitle("Quizzes")
                .toolbar {
                    // Añadir el contador al lado derecho del título
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            VStack {
                                // Contador de aciertos en verde
                                Text("Aciertos: \(quizzesAcertados.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                
                                // Total de aciertos persistentes en azul
                                Text("Total: \(quizzesModel.totalAcertadosRecord)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            // Botón para recargar quizzes
                            Button(action: {
                                reloadQuizzes()
                            }) {
                                Image(systemName: "arrow.clockwise")
                            }
                            .accessibilityLabel("Recargar quizzes")
                        }
                    }
                }
                .task {
                    if quizzesModel.quizzes.count == 0 {
                        quizzesModel.loadQuizzesFromServer()  // Cargar los quizzes al aparecer la vista
                    }
                }
            }
            .background(Color.clear)
        }
        .background(Color.clear)
    }
    
    // Computed property para obtener los quizzes filtrados
    private var filteredQuizzes: [QuizItem] {
        if showQuizzesPendientes {
            return quizzesModel.quizzes.filter { !quizzesAcertados.contains($0.id) }
        } else {
            // Devuelve todos los quizzes si el Toggle está desactivado
            return quizzesModel.quizzes
        }
    }
    
    // Método para recargar quizzes y reiniciar los aciertos
    private func reloadQuizzes() {
        quizzesModel.loadQuizzesFromServer()
        quizzesAcertados = []  // Reiniciar el contador de aciertos
    }
}
