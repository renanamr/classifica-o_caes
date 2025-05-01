import 'dart:typed_data';
import 'package:classificacao_caes/src/widgets/background_card.dart';
import 'package:classificacao_caes/src/widgets/button_core.dart';
import 'package:classificacao_caes/src/widgets/image_area.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';

class DogClassifierPage extends StatefulWidget {
  const DogClassifierPage({super.key});

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
      debugPrint('Modelo carregado com sucesso');
    } catch (e) {
      debugPrint('Erro ao carregar o modelo: $e');
    }
  }

  Future<void> _pickImageFromWeb() async {
    final String url = _urlController.text;

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
    _classifyImage();
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageInBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = Uint8List.fromList(imageInBytes);
      });

      _classifyImage();
    }
  }

  Future<void> _classifyImage() async {
    img.Image image = img.decodeImage(_imageBytes!)!;
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
      backgroundColor: Colors.blue[50],
      body: BackgroundCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Classificador", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            ImageArea(imageBytes: _imageBytes,),

            const SizedBox(height: 26),

            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "URL da imagem",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.link),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ButtonCore(
                    onPressed: _pickImageFromGallery,
                    icon: Icons.photo,
                    label: "Galeria",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ButtonCore(
                    onPressed: _pickImageFromWeb,
                    icon: Icons.download,
                    label: "Buscar URL",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            if (_result != null)
              Text(_result!, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

}