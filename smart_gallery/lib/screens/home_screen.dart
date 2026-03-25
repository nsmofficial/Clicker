import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../models/photo_group.dart';
import '../utils/category_mapper.dart';
import 'group_detail_screen.dart';
import '../widgets/group_grid_tile.dart';
import '../widgets/scanning_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Smart Gallery',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: provider.isDone
                ? TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.people),
                        text: 'People (${provider.personGroups.length})',
                      ),
                      Tab(
                        icon: const Icon(Icons.category),
                        text: 'Categories (${provider.categoryGroups.length})',
                      ),
                    ],
                  )
                : null,
            actions: [
              if (provider.isDone)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Rescan',
                  onPressed: () => provider.startScanning(),
                ),
            ],
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(GalleryProvider provider) {
    if (!provider.isDone) {
      return ScanningView(
        status: provider.status,
        statusMessage: provider.statusMessage,
        progress: provider.progress,
        errorMessage: provider.errorMessage,
        onStart: () => provider.startScanning(),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPeopleTab(provider),
        _buildCategoriesTab(provider),
      ],
    );
  }

  Widget _buildPeopleTab(GalleryProvider provider) {
    final groups = provider.personGroups;

    if (groups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No people detected',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Photos with faces will be grouped here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return GroupGridTile(
          group: groups[index],
          icon: Icons.person,
          onTap: () => _openGroup(groups[index]),
        );
      },
    );
  }

  Widget _buildCategoriesTab(GalleryProvider provider) {
    final groups = provider.categoryGroups;

    if (groups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No categories detected',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return GroupGridTile(
          group: group,
          emoji: CategoryMapper.getCategoryIcon(group.name),
          onTap: () => _openGroup(group),
        );
      },
    );
  }

  void _openGroup(PhotoGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupDetailScreen(group: group),
      ),
    );
  }
}
