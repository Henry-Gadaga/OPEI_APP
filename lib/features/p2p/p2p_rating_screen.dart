import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/data/models/p2p_trade.dart';
import 'package:tt1/data/models/p2p_ad.dart';
import 'package:tt1/theme.dart';

/// A clean, Apple-style rating screen that appears after releasing escrow.
/// User can rate the counterparty, then either submit or dismiss.
class P2PRatingScreen extends ConsumerStatefulWidget {
  final P2PTrade trade;

  const P2PRatingScreen({super.key, required this.trade});

  @override
  ConsumerState<P2PRatingScreen> createState() => _P2PRatingScreenState();
}

class _P2PRatingScreenState extends ConsumerState<P2PRatingScreen> {
  int _selectedScore = 0;
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;
  String? _errorMessage;

  static const _ratingTags = [
    'Fast',
    'Friendly',
    'Professional',
    'Clear',
    'Reliable',
    'Patient',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _counterpartLabel {
    switch (widget.trade.ad.type) {
      case P2PAdType.buy:
        return 'Buyer';
      case P2PAdType.sell:
        return 'Seller';
    }
  }

  Future<void> _submitRating() async {
    if (_selectedScore == 0) {
      setState(() => _errorMessage = 'Please select a star rating.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(p2pRepositoryProvider);
      await repository.rateTrade(
        tradeId: widget.trade.id,
        score: _selectedScore,
        comment: _commentController.text.trim().isNotEmpty ? _commentController.text.trim() : null,
        tags: _selectedTags.isNotEmpty ? _selectedTags.toList(growable: false) : null,
      );

      if (!mounted) return;

      // Navigate to Orders tab instead of just popping
      context.go('/p2p');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Failed to submit rating. Please try again.';
      });
    }
  }

  void _dismiss() {
    context.go('/p2p');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    'Rate $_counterpartLabel',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How was your experience?',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: OpeiColors.iosLabelSecondary,
                      letterSpacing: -0.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final isSelected = starIndex <= _selectedScore;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedScore = starIndex;
                            _errorMessage = null;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 36,
                            color: isSelected ? Colors.amber : OpeiColors.grey300,
                          ),
                        ),
                      );
                    }),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: OpeiColors.errorRed,
                        letterSpacing: -0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Tags
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What went well?',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ratingTags.map((tag) {
                      final isActive = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isActive) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                        child: _buildTagPill(tag, isActive: isActive),
                      );
                    }).toList(growable: false),
                  ),

                  const SizedBox(height: 24),

                  // Comment
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Comments',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    minLines: 3,
                    maxLength: 300,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: [LengthLimitingTextInputFormatter(300)],
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: OpeiColors.iosLabelTertiary,
                        letterSpacing: -0.1,
                      ),
                      filled: true,
                      fillColor: OpeiColors.iosSurfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      counterStyle: textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: OpeiColors.iosLabelSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      letterSpacing: -0.1,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OpeiColors.pureBlack,
                        foregroundColor: OpeiColors.pureWhite,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(OpeiColors.pureWhite),
                              ),
                            )
                          : Text(
                              'Submit Rating',
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: OpeiColors.pureWhite,
                                letterSpacing: -0.2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Close button at top right
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: OpeiColors.pureBlack,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagPill(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isActive ? OpeiColors.pureBlack : OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? OpeiColors.pureBlack : OpeiColors.iosSeparator,
          width: isActive ? 1 : 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? OpeiColors.pureWhite : OpeiColors.pureBlack,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
