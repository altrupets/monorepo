import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/widgets/organisms/messages_stream.dart';
import 'package:altrupets/core/widgets/molecules/chat_input_field.dart';
import 'package:altrupets/features/messages/presentation/providers/messages_provider.dart';
import 'package:altrupets/features/profile/presentation/providers/profile_provider.dart';

import 'package:altrupets/features/organizations/presentation/pages/organization_detail_page.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({
    required this.organizationId,
    required this.organizationName,
    this.onBack,
    super.key,
  });

  final String organizationId;
  final String organizationName;
  final VoidCallback? onBack;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(markMessagesAsReadProvider)(widget.organizationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? deepLinkType, String? deepLinkId}) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && deepLinkType == null) return;

    setState(() => _isSending = true);

    try {
      final sendMessage = ref.read(sendMessageProvider);
      await sendMessage(
        organizationId: widget.organizationId,
        text: text.isEmpty ? 'Compartió una solicitud' : text,
        deepLinkType: deepLinkType,
        deepLinkId: deepLinkId,
      );
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showDeepLinkDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Compartir Solicitud de Captura'),
                subtitle: const Text(
                  'Envía un enlace a una solicitud de captura',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCaptureRequestDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.pets, color: Colors.green),
                title: const Text('Compartir Rescate'),
                subtitle: const Text('Envía un enlace a un rescate'),
                onTap: () {
                  Navigator.pop(context);
                  _showRescueDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCaptureRequestDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitud de Captura'),
        content: const Text(
          'Para compartir una solicitud de captura, copia el enlace de la aplicación y pégalo aquí como mensaje.\n\n'
          'El formato debería ser: altrupets://capture/[id]',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showRescueDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rescate'),
        content: const Text(
          'Para compartir un rescate, copia el enlace de la aplicación y pégalo aquí como mensaje.\n\n'
          'El formato debería ser: altrupets://rescue/[id]',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.organizationId),
    );
    final userAsync = ref.watch(currentUserProvider);
    final currentUserId = userAsync.whenData((u) => u?.id).value ?? '';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
        title: Text(
          widget.organizationName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => MessagesStream(
                messages: messages,
                currentUserId: currentUserId,
                onDeepLinkTap: (deepLinkType, deepLinkId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tocaste un deep link: $deepLinkType/$deepLinkId',
                      ),
                      action: SnackBarAction(
                        label: 'Ver',
                        onPressed: () {
                          if (deepLinkType == 'organization') {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => OrganizationDetailPage(
                                  organizationId: deepLinkId,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar mensajes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.refresh(
                        messagesStreamProvider(widget.organizationId),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ChatInputField(
            controller: _messageController,
            onSend: () => _sendMessage(),
            onDeepLinkTap: _showDeepLinkDialog,
            isLoading: _isSending,
          ),
        ],
      ),
    );
  }
}
