import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/widgets/app_loader.dart';
import '../../constants/product_detail_constants.dart';

/// Lecteur vidéo pour la vidéo illustrative du produit.
/// Affiché à la fin du carrousel, après toutes les images.
class ProductDetailVideoPlayer extends StatefulWidget {
  const ProductDetailVideoPlayer({
    super.key,
    required this.videoUrl,
  });

  final String videoUrl;

  @override
  State<ProductDetailVideoPlayer> createState() =>
      _ProductDetailVideoPlayerState();
}

class _ProductDetailVideoPlayerState extends State<ProductDetailVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initError = false;

  @override
  void initState() {
    super.initState();
    // Délai d'une frame pour éviter les erreurs de canal sur iOS (channel-error)
    WidgetsBinding.instance.addPostFrameCallback((_) => _initVideo());
  }

  Future<void> _initVideo() async {
    if (!mounted) return;
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    controller.addListener(_onControllerUpdate);
    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initError = false;
      });
    } on PlatformException catch (_) {
      if (kDebugMode) {
        // Ignorer en debug pour éviter le spam ; l'erreur est déjà loguée par Flutter
      }
      if (mounted) {
        controller.dispose();
        setState(() {
          _controller = null;
          _initError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        controller.dispose();
        setState(() {
          _controller = null;
          _initError = true;
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_initError || (_controller != null && _controller!.value.hasError)) {
      return SizedBox(
        height: ProductDetailConstants.imageHeight,
        child: Center(
          child: Icon(
            Icons.videocam_off,
            size: 64,
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return SizedBox(
        height: ProductDetailConstants.imageHeight,
        child: Center(
          child: AppLoader(size: 28, color: theme.colorScheme.primary),
        ),
      );
    }

    final controller = _controller!;

    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
        setState(() {});
      },
      child: SizedBox(
        height: ProductDetailConstants.imageHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            if (!controller.value.isPlaying)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
