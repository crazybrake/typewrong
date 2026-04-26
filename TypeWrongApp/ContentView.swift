import SwiftUI

struct ContentView: View {
    @State private var sampleText = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.90, blue: 0.78),
                    Color(red: 0.88, green: 0.93, blue: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("TypeWrong")
                        .font(.system(size: 40, weight: .bold, design: .rounded))

                    Text("Русская раскладка на экране, английский ввод в поле.")
                        .font(.title3.weight(.semibold))

                    exampleCard

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Проверка")
                            .font(.headline)

                        Text("После включения клавиатуры переключитесь на неё через глобус и попробуйте набрать текст здесь.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $sampleText)
                            .frame(minHeight: 140)
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Как включить")
                            .font(.headline)

                        Text("1. Откройте Settings -> General -> Keyboard -> Keyboards.")
                        Text("2. Нажмите Add New Keyboard.")
                        Text("3. Выберите TypeWrong Keyboard.")
                        Text("4. В любом поле ввода переключитесь на новую клавиатуру через кнопку глобуса.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    Text("Ограничение iOS: в некоторых secure-полях система всё равно принудительно покажет стандартную клавиатуру Apple.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
            }
        }
    }

    private var exampleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Примеры")
                .font(.headline)

            Text("пароль -> gfhjkm")
            Text("привет -> ghbdtn")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
