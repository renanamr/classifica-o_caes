# 🐶 Dog Classifier App

Este é um aplicativo Flutter que classifica raças de cães a partir de imagens fornecidas via URL ou escolhidas da galeria do dispositivo, utilizando um modelo treinado em TensorFlow Lite.

## 📸 Funcionalidades

- Classificação de raças de cães entre 10 categorias:
  - Beagle
  - Boxer
  - Bulldog
  - Dachshund
  - German Shepherd
  - Golden Retriever
  - Labrador Retriever
  - Poodle
  - Rottweiler
  - Yorkshire Terrier
- Entrada de imagem por URL
- Entrada de imagem via **galeria do dispositivo**
- Interface amigável com visualização da imagem e resultado da classificação

## 🧠 Modelo

O modelo `.tflite` espera imagens de entrada no formato **64x64 RGB**, com saída de **10 classes** correspondentes às raças listadas acima.

## ⚙️ Instalação

### Pré-requisitos

- Flutter SDK (versão recomendada: 3.19 ou superior)
- Android Studio ou VS Code com extensão Flutter
- Dispositivo físico ou emulador

### Passos

1. Clone o repositório:

   ```bash
   git clone https://github.com/seu-usuario/dog_classifier_flutter.git
   cd dog_classifier_flutter
   ```

2. Instale as dependências:

   ```bash
   flutter pub get
   ```

3. Instale as bibliotecas nativas do TensorFlow Lite para Android:

   ```bash
   chmod +x install.sh
   ./install.sh
   ```

   > 💡 O script `install.sh` baixa e organiza automaticamente as bibliotecas `.so` necessárias para rodar o modelo no Android.

4. Rode o projeto:

   ```bash
   flutter run
   ```

## 📱 Permissões necessárias

Para Android, adicione as seguintes permissões no `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

## 📦 Dependências principais

- [`tflite_flutter`](https://pub.dev/packages/tflite_flutter)
- [`tflite_flutter_helper`](https://pub.dev/packages/tflite_flutter_helper)
- [`image`](https://pub.dev/packages/image)
- [`http`](https://pub.dev/packages/http)
- [`image_picker`](https://pub.dev/packages/image_picker)