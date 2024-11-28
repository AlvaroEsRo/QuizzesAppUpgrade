import SwiftUI

struct QuizzesView: View {
    @StateObject private var quizzesModel = QuizzesModel()  // Crear instancia de QuizzesModel
    @State private var quizzesAcertados : [QuizItem.ID] = []  // Mantener los quizzes acertados
    @State private var showQuizzesPendientes: Bool = true  // Opción seleccionada en el Picker
    
    var body: some View {
        NavigationView {
            VStack {
                    // Picker para elegir entre Mostrar Todos o Mostrar No Acertados
                Toggle("Mostrar Quizzes Pendientes", isOn: $showQuizzesPendientes)
                    .padding([.top, .horizontal])
                        
                // Filtrar los quizzes según la opción seleccionada
                List(filteredQuizzes) { quiz in
                    NavigationLink(destination: QuizView(quizzesAcertados: $quizzesAcertados, quiz: quiz)) {
                        RowView(quiz: quiz)
                    }
                }
                .background(Color.clear)
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
            }.background(Color.clear)
            
        }.background(Color.clear)
    }
    
    // Computed property para obtener los quizzes filtrados
    private var filteredQuizzes: [QuizItem] {
        if showQuizzesPendientes {
               return quizzesModel.quizzes.filter { !quizzesAcertados.contains($0.id) }
           } else {
               // Devuelve solo los quizzes que no han sido acertados si el Toggle está desactivado
               return quizzesModel.quizzes  // Devuelve todos los quizzes si el Toggle está activado
           }
       }
}

#Preview {
    QuizzesView()
}
