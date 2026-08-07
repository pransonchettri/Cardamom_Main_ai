import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/data/diseases_data.dart';
import 'package:plant_ai/models/disease.dart';
import 'package:plant_ai/screens/care_guide_screen.dart';
import 'package:plant_ai/screens/disease_detail_screen.dart';
import 'package:plant_ai/services/favorites_service.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/app_route.dart';
import 'package:plant_ai/widgets/disease_leaf_illustration.dart';

class LibraryScreen extends StatefulWidget {
  final bool startWithFavorites;

  const LibraryScreen({super.key, this.startWithFavorites = false});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _controller = TextEditingController();
  String _query = '';
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _favoritesOnly = widget.startWithFavorites;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesService>();

    final results = DiseasesData.all.where((d) {
      if (_favoritesOnly && !favorites.isFavorite(d.id)) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return d.name.toLowerCase().contains(q) || d.shortDescription.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Care guide',
            onPressed: () => Navigator.push(context, AppRoute.to(const CareGuideScreen())),
            icon: const Icon(Icons.health_and_safety_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: context.mutedColor, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.emeraldLight),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cardamom knowledge',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.primaryText)),
                    const SizedBox(height: 3),
                    Text('Learn what to look for before you scan.',
                        style: TextStyle(fontSize: 12, color: context.secondaryText)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor),
            ),
            child: TextField(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: context.primaryText),
              decoration: InputDecoration(
                hintText: 'Search diseases…',
                hintStyle: TextStyle(color: context.secondaryText),
                prefixIcon: Icon(Icons.search_rounded, color: context.secondaryText),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close_rounded, color: context.secondaryText),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: !_favoritesOnly,
                onSelected: (_) => setState(() => _favoritesOnly = false),
                selectedColor: AppColors.forest,
                labelStyle: TextStyle(
                  color: !_favoritesOnly ? Colors.white : context.primaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.borderColor),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                avatar: Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: _favoritesOnly ? Colors.white : AppColors.warmAccentDeep,
                ),
                label: const Text('Favorites'),
                selected: _favoritesOnly,
                onSelected: (_) => setState(() => _favoritesOnly = true),
                selectedColor: AppColors.forest,
                labelStyle: TextStyle(
                  color: _favoritesOnly ? Colors.white : context.primaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                backgroundColor: context.cardColor,
                side: BorderSide(color: context.borderColor),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${results.length} disease${results.length == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.secondaryText),
          ),
          const SizedBox(height: 10),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  _favoritesOnly ? 'No favorites yet. Tap the star on a disease to save it here.' : 'No diseases match "$_query"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.secondaryText),
                ),
              ),
            )
          else
            ...results.map((d) => _DiseaseListTile(disease: d)),
        ],
      ),
    );
  }
}

class _DiseaseListTile extends StatelessWidget {
  final Disease disease;

  const _DiseaseListTile({required this.disease});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesService>();
    final isFav = favorites.isFavorite(disease.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: () => Navigator.push(context, AppRoute.to(DiseaseDetailScreen(disease: disease))),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: disease.accent.withOpacity(context.isDark ? 0.16 : 0.10),
            shape: BoxShape.circle,
          ),
          child: DiseaseLeafIllustration(
            pattern: disease.symptomPattern,
            accent: disease.accent,
            size: 32,
          ),
        ),
        title: Text(disease.name, style: TextStyle(fontWeight: FontWeight.w800, color: context.primaryText)),
        subtitle: Text(disease.shortDescription, style: TextStyle(fontSize: 12, color: context.secondaryText)),
        trailing: IconButton(
          onPressed: () => favorites.toggle(disease.id),
          icon: Icon(
            isFav ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFav ? AppColors.warmAccentDeep : context.secondaryText,
          ),
        ),
      ),
    );
  }
}
