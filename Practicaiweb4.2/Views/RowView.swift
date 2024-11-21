import SwiftUI

struct RowView: View {
    let quiz: QuizItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Pregunta y estrella de favorito
            HStack {
                Text(quiz.question)  // Mostrar la pregunta
                    .font(.body) // Ajustado para que sea más legible
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.trailing, 10)
                
                Spacer()
                
                if quiz.favourite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .imageScale(.medium)
                } else {
                    Image(systemName: "star")
                        .foregroundColor(.gray)
                        .imageScale(.medium)
                }
            }
            .padding([.top, .horizontal])
            .background(Color.clear)

            // Imagen adjunta, si existe
            if let imageUrl = quiz.attachment?.url {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity) // Ajustado para pantalla pequeña
                        .cornerRadius(12)
                        .clipped()
                        .shadow(radius: 4)
                        .padding(.vertical, 5)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        
                        .padding(.top, 5)
                }
            }
            
            // Información del autor
            HStack(spacing: 12) {
                if let autorphoto = quiz.author?.photo?.url {
                    AsyncImage(url: autorphoto) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                            .padding(2)
                    }
                }
                
                if let author = quiz.author {
                    Text(author.profileName ?? "Desconocido")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                Spacer()
            }
            .padding([.horizontal, .bottom], 10)
            .background(Color.clear)
        }
        
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.bottom, 10)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .background(Color.clear)
       
    }
}

#Preview {
    let quizItem = QuizItem(id: 1, question: "¿Cuál es la capital de Francia?", answer: "París", author: nil, attachment: nil, favourite: true)
    RowView(quiz: quizItem)
}
