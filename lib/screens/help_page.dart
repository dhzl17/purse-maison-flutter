import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(selectedIndex: -1, body: _HelpBody());
  }
}

class _HelpBody extends StatelessWidget {
  const _HelpBody();

  static const List<_TopicItem> _leftTopics = [
    _TopicItem(
      title: 'How to create new consignment',
      subtitle: 'Learn how to create and manage a new consignment.',
    ),
    _TopicItem(
      title: 'How to add new client assignment',
      subtitle: 'Step-by-step guide on adding new client assignment.',
    ),
    _TopicItem(
      title: 'Understanding sales forecasting',
      subtitle: 'Learn how forecasts are generated and interpreted.',
    ),
  ];

  static const List<_TopicItem> _rightTopics = [
    _TopicItem(
      title: 'Managing inventory',
      subtitle: 'Learn how to update stock, categories, and items.',
    ),
    _TopicItem(
      title: 'User roles and permisions',
      subtitle: 'Understand user roles and access levels.',
    ),
    _TopicItem(
      title: 'Reports overview',
      subtitle: 'Learn how to generate and export reports.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 800;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help Center',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Find answers, guides, and support for using Purse Maison.',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              const _HelpSearchField(),
              const SizedBox(height: 24),
              const Text(
                'How can we help you?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickLinksRow(isWide),
              const SizedBox(height: 24),
              const Text(
                'Popular Topics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildTopicsGrid(isWide),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickLinksRow(bool isWide) {
    final cards = const [
      _HelpQuickLinkCard(
        icon: Icons.menu_book_outlined,
        title: 'User Guides',
        subtitle: 'Step-by-step guides on how to use each feature.',
      ),
      _HelpQuickLinkCard(
        icon: Icons.help_outline,
        title: 'FAQs',
        subtitle: 'Find answers to common questions.',
      ),
      _HelpQuickLinkCard(
        icon: Icons.headset_mic_outlined,
        title: 'Contact Support',
        subtitle: 'Get in touch with our support team.',
      ),
    ];

    if (isWide) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 16),
                child: cards[i],
              ),
            ),
        ],
      );
    }
    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          cards[i],
          if (i != cards.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTopicsGrid(bool isWide) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _TopicColumn(topics: _leftTopics)),
          const SizedBox(width: 16),
          Expanded(child: _TopicColumn(topics: _rightTopics)),
        ],
      );
    }
    return _TopicColumn(topics: [..._leftTopics, ..._rightTopics]);
  }
}

class _HelpSearchField extends StatelessWidget {
  const _HelpSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search for help articles, topics, or keywords...',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(fontSize: 13.5, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpQuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelpQuickLinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardNavyDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicItem {
  final String title;
  final String subtitle;
  const _TopicItem({required this.title, required this.subtitle});
}

class _TopicColumn extends StatelessWidget {
  final List<_TopicItem> topics;
  const _TopicColumn({required this.topics});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          for (int i = 0; i < topics.length; i++) ...[
            _TopicRow(item: topics[i]),
            if (i != topics.length - 1)
              const Divider(height: 1, color: AppColors.borderLight),
          ],
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  final _TopicItem item;
  const _TopicRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
