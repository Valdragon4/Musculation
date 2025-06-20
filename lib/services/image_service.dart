import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Demande toutes les permissions nécessaires au démarrage
  Future<bool> requestInitialPermissions() async {
    try {
      debugPrint('=== Début de la demande des permissions initiales ===');
      
      // Demander la permission des photos
      debugPrint('Demande de la permission des photos...');
      final photosStatus = await Permission.photos.request();
      debugPrint('Statut permission photos: $photosStatus');
      
      // Demander la permission de la caméra
      debugPrint('Demande de la permission de la caméra...');
      final cameraStatus = await Permission.camera.request();
      debugPrint('Statut permission caméra: $cameraStatus');
      
      // Vérifier si les permissions sont accordées
      final hasPhotos = photosStatus.isGranted;
      final hasCamera = cameraStatus.isGranted;
      
      debugPrint('Résumé des permissions:');
      debugPrint('- Photos: ${hasPhotos ? 'Accordée' : 'Refusée'}');
      debugPrint('- Caméra: ${hasCamera ? 'Accordée' : 'Refusée'}');
      debugPrint('=== Fin de la demande des permissions ===');
      
      return hasPhotos && hasCamera;
    } catch (e) {
      debugPrint('Erreur lors de la demande des permissions: $e');
      return false;
    }
  }

  // Sélectionner une image depuis la galerie
  Future<String?> pickImageFromGallery() async {
    try {
      debugPrint('Sélection d\'une image depuis la galerie');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('Aucune image sélectionnée');
        return null;
      }

      return await _saveImage(image);
    } catch (e) {
      debugPrint('Erreur lors de la sélection depuis la galerie: $e');
      return null;
    }
  }

  // Prendre une photo avec la caméra
  Future<String?> takePhoto() async {
    try {
      debugPrint('Prise d\'une photo avec la caméra');
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) {
        debugPrint('Aucune photo prise');
        return null;
      }

      return await _saveImage(photo);
    } catch (e) {
      debugPrint('Erreur lors de la prise de photo: $e');
      return null;
    }
  }

  // Sauvegarder l'image dans le dossier de l'application
  Future<String?> _saveImage(XFile image) async {
    try {
      debugPrint('Sauvegarde de l\'image: ${image.path}');
      
      // Obtenir le dossier de l'application
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(image.path);
      final fileName = '$timestamp$extension';
      final destinationPath = path.join(appDir.path, fileName);
      
      debugPrint('Chemin de destination: $destinationPath');
      
      // Copier l'image
      final File sourceFile = File(image.path);
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
        debugPrint('Image sauvegardée avec succès');
        return destinationPath;
      } else {
        debugPrint('Le fichier source n\'existe pas');
        return null;
      }
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'image: $e');
      return null;
    }
  }
} 