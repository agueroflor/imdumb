import 'package:flutter/material.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/service_locator.dart';

class RecommendDialog extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String movieOverview;

  const RecommendDialog({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.movieOverview,
  });

  @override
  State<RecommendDialog> createState() => _RecommendDialogState();
}

class _RecommendDialogState extends State<RecommendDialog> {
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _analyticsService = serviceLocator<AnalyticsService>();
  int _characterCount = 0;
  static const int _minCharacters = 15;
  static const int _maxCharacters = 256;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _commentController.removeListener(_updateCharacterCount);
    _commentController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _commentController.text.length;
    });
  }

  void _handleRecommend() {
    if (_formKey.currentState?.validate() ?? false) {
      final comment = _commentController.text.trim();

      _analyticsService.logEvent(
        name: 'movie_recommended',
        parameters: {
          'movie_id': widget.movieId,
          'movie_title': widget.movieTitle,
          'comment_length': comment.length,
          'has_comment': comment.isNotEmpty,
        },
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recomendación enviada!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Color _getCounterColor() {
    if (_characterCount < _minCharacters) {
      return Colors.red;
    } else if (_characterCount > _maxCharacters) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recomendar: ${widget.movieTitle}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sinopsis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.movieOverview.isNotEmpty
                          ? widget.movieOverview
                          : 'Sin descripción disponible',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comentario',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCounterColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCounterColor(),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$_characterCount/$_maxCharacters',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getCounterColor(),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: _maxCharacters,
                  decoration: InputDecoration(
                    hintText: 'Por qué recomendarías esta película?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, ingresa un comentario';
                    }
                    if (value.trim().length < _minCharacters) {
                      return 'Mínimo $_minCharacters caracteres';
                    }
                    if (value.trim().length > _maxCharacters) {
                      return 'Máximo $_maxCharacters caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleRecommend,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
