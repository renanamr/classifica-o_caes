import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classificador de Cães',
      home: DogClassifierPage(),
    );
  }
}

class DogClassifierPage extends StatefulWidget {
  @override
  State<DogClassifierPage> createState() => _DogClassifierPageState();
}

class _DogClassifierPageState extends State<DogClassifierPage> {
  final TextEditingController _urlController = TextEditingController();
  Interpreter? _interpreter;
  String? _result;
  Uint8List? _imageBytes;
  final int _inputSize = 64;

  final List<String> _classes = [
    'Beagle',
    'Boxer',
    'Bulldog',
    'Dachshund',
    'German_Shepherd',
    'Golden_Retriever',
    'Labrador_Retriever',
    'Poodle',
    'Rottweiler',
    'Yorkshire_Terrier',
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('modelo.tflite');
      print('Modelo carregado com sucesso');
    } catch (e) {
      print('Erro ao carregar o modelo: $e');
    }
  }

  Future<void> _classifyImage(String url) async {
    setState(() {
      _result = "Classificando...";
      _imageBytes = null;
    });

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      setState(() => _result = "Erro ao baixar a imagem.");
      return;
    }

    _imageBytes = response.bodyBytes;
    img.Image? image = img.decodeImage(response.bodyBytes);
    if (image == null) {
      setState(() => _result = "Erro ao processar imagem.");
      return;
    }

    img.Image resizedImage = img.copyResize(image, width: _inputSize, height: _inputSize);

    // Convertendo imagem para input do modelo
    TensorImage tensorImage = TensorImage(TfLiteType.float32);
    tensorImage.loadImage(resizedImage);

    // Normalização simples (0-255 para 0-1)
    ImageProcessor processor = ImageProcessorBuilder()
        .add(ResizeOp(_inputSize, _inputSize, ResizeMethod.bilinear))
        .add(NormalizeOp(0, 255))
        .build();
    tensorImage = processor.process(tensorImage);

    TensorBuffer output = TensorBuffer.createFixedSize([1, _classes.length], TfLiteType.float32);
    _interpreter!.run(tensorImage.buffer, output.buffer);

    List<double> scores = output.getDoubleList();
    int maxIdx = scores.indexWhere((e) => e == scores.reduce((a, b) => a > b ? a : b));

    setState(() {
      _result =
      "Raça: ${_classes[maxIdx]}\nConfiança: ${(scores[maxIdx] * 100).toStringAsFixed(2)}%";
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageInBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = Uint8List.fromList(imageInBytes);
      });

      _classifyImageFromGallery(pickedFile.path);
    }
  }

  Future<void> _classifyImageFromGallery(String path) async {
    img.Image image = img.decodeImage(await _imageBytes!)!;
    img.Image resizedImage = img.copyResize(image, width: _inputSize, height: _inputSize);

    TensorImage tensorImage = TensorImage(TfLiteType.float32);
    tensorImage.loadImage(resizedImage);

    ImageProcessor processor = ImageProcessorBuilder()
        .add(ResizeOp(_inputSize, _inputSize, ResizeMethod.bilinear))
        .add(NormalizeOp(0, 255))
        .build();
    tensorImage = processor.process(tensorImage);

    TensorBuffer output = TensorBuffer.createFixedSize([1, _classes.length], TfLiteType.float32);
    _interpreter!.run(tensorImage.buffer, output.buffer);

    List<double> scores = output.getDoubleList();
    int maxIdx = scores.indexWhere((e) => e == scores.reduce((a, b) => a > b ? a : b));

    setState(() {
      _result =
      "Raça: ${_classes[maxIdx]}\nConfiança: ${(scores[maxIdx] * 100).toStringAsFixed(2)}%";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classificador de Cães')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL da Imagem',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _classifyImage(_urlController.text),
                  child: Text('Classificar'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: Text('Selecionar Imagem'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _imageBytes != null
                ? Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(_imageBytes!, height: 200),
              ),
            )
                : Container(),
            SizedBox(height: 16),
            if (_result != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _result ?? 'Resultado aparecerá aqui',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
