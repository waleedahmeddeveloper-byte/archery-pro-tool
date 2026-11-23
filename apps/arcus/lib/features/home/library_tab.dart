import 'package:material_ui/material_ui.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  static const _guides = [
    ('Measuring FOC the AMO way', 'Balance point, shaft length, and common errors.'),
    ('Kinetic energy vs momentum', 'Why hunters look at both numbers.'),
    ('Spine is a starting point', 'Static charts vs dynamic tune.'),
    ('IBO is not your hunting speed', 'How ratings are defined and why chronographs win.'),
    ('Safety before the season', 'Minimum arrow mass, inspection, and broadhead tune.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _guides.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              'Original offline guides (not copied from other sites).',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          }
          final g = _guides[index - 1];
          return Card(
            child: ListTile(
              title: Text(g.$1),
              subtitle: Text(g.$2),
              leading: const Icon(Icons.article_outlined),
            ),
          );
        },
      ),
    );
  }
}
