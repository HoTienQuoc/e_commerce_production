import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/chat/domain/entities/chat_message_entity.dart';
import 'package:frontend_admin/features/chat/presentation/widgets/typing_widget.dart';

enum MessageState { sending, processing, sent, failed }

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final VoidCallback? onFeedback;
  final VoidCallback? onRetry;
  final bool showMetadata;
  final MessageState? state;
  final bool showProcessingIndicator;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onFeedback,
    this.onRetry,
    this.showMetadata = true,
    this.state,
    this.showProcessingIndicator = false,
  });

  bool get isUserMessage => message.intent == 'user_query';

  MessageState get effectiveState {
    if (state != null) return state!;
    return MessageState.sent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUserMessage) ...[
            _buildQueryBubble(),
            if (showProcessingIndicator) ...[
              const SizedBox(height: 16),
              _buildProgressIndicator(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accentGreen.withAlpha(
              (0.7 * 255).round(),
            ),
            child: const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withAlpha((0.7 * 255).round()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: AppTheme.borderColor.withAlpha((0.3 * 255).round()),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withAlpha(
                        (0.1 * 255).round(),
                      ),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                      border: Border.all(
                        color: AppTheme.accentGreen.withAlpha(
                          (0.3 * 255).round(),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Processing',
                          style: AppTheme.bodySmall().copyWith(
                            color: AppTheme.accentGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const TypingWidget(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.smart_toy,
                              size: 12,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Assistant is thinking...',
                              style: AppTheme.bodySmall().copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryBubble() {
    final isActive = effectiveState == MessageState.sending;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.accentBlue.withAlpha(179)
                  : AppTheme.accentBlue.withAlpha(229),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentBlue.withAlpha(76),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        message.query,
                        style: AppTheme.bodyMedium().copyWith(
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textPrimary.withAlpha(204),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                _buildUserLabel(isActive),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildUserAvatar(isActive),
      ],
    );
  }

  Widget _buildUserAvatar(bool isActive) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: effectiveState == MessageState.failed
          ? AppTheme.error.withAlpha(179)
          : AppTheme.accentBlue,
      child: Icon(
        effectiveState == MessageState.failed
            ? Icons.error_outline
            : Icons.person,
        size: 16,
      ),
    );
  }

  Widget _buildUserLabel(bool isActive) {
    String labelText;
    switch (effectiveState) {
      case MessageState.sending:
        labelText = 'Sending...';
        break;
      case MessageState.processing:
        labelText = 'Processing...';
      case MessageState.failed:
        labelText = 'Failed';
        break;
      default:
        labelText = 'User';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          effectiveState == MessageState.failed
              ? Icons.error_outline
              : Icons.person,
          size: 12,
          color: effectiveState == MessageState.failed
              ? AppTheme.error.withAlpha(204)
              : AppTheme.textPrimary.withAlpha(179),
        ),
        const SizedBox(width: 4),
        Text(
          labelText,
          style: AppTheme.bodySmall().copyWith(
            color: effectiveState == MessageState.failed
                ? AppTheme.error.withAlpha(204)
                : AppTheme.textPrimary.withAlpha(179),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
