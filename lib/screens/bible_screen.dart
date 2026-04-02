import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/bible_quote.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedBook;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get unique book names from quotes
  List<String> _getBooks(List<BibleQuote> quotes) {
    final books = <String>[];
    for (final q in quotes) {
      if (!books.contains(q.carte)) {
        books.add(q.carte);
      }
    }
    return books;
  }

  /// Filter books by search query
  List<String> _filterBooks(List<String> books) {
    if (_searchQuery.isEmpty) return books;
    final query = _searchQuery.toLowerCase();
    return books.where((b) => b.toLowerCase().contains(query)).toList();
  }

  /// Get quotes for a specific book, sorted by chapter and verse
  List<BibleQuote> _getBookQuotes(List<BibleQuote> quotes, String book) {
    final bookQuotes = quotes.where((q) => q.carte == book).toList();
    bookQuotes.sort((a, b) {
      final c = a.capitol.compareTo(b.capitol);
      if (c != 0) return c;
      return a.verset.compareTo(b.verset);
    });
    return bookQuotes;
  }

  /// Get unique chapters for a book
  List<int> _getChapters(List<BibleQuote> bookQuotes) {
    final chapters = <int>{};
    for (final q in bookQuotes) {
      chapters.add(q.capitol);
    }
    final list = chapters.toList();
    list.sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_selectedBook ?? 'Biblie'),
        leading: _selectedBook != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedBook = null),
              )
            : const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.auto_stories, color: AppTheme.goldColor),
              ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.goldColor),
            );
          }

          final quotes = provider.bibleQuotes;
          if (quotes.isEmpty) {
            return const Center(
              child: Text('Nu s-au găsit citate biblice.'),
            );
          }

          if (_selectedBook != null) {
            return _buildBookView(quotes, _selectedBook!);
          }

          return _buildBookList(quotes);
        },
      ),
    );
  }

  Widget _buildBookList(List<BibleQuote> quotes) {
    final allBooks = _getBooks(quotes);
    final filteredBooks = _filterBooks(allBooks);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Caută o carte (ex: Marcu, Psalmi...)',
              hintStyle: TextStyle(color: AppTheme.creamColor.withOpacity(0.4)),
              prefixIcon: const Icon(Icons.search, color: AppTheme.goldColor),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.goldColor),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.goldColor, width: 2),
              ),
            ),
            style: TextStyle(color: AppTheme.creamColor),
          ),
        ),

        // Book list
        Expanded(
          child: filteredBooks.isEmpty
              ? Center(
                  child: Text(
                    'Nicio carte găsită pentru "$_searchQuery"',
                    style: TextStyle(color: AppTheme.creamColor.withOpacity(0.6)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    final bookQuotes = _getBookQuotes(quotes, book);
                    final chapters = _getChapters(bookQuotes);
                    final verseCount = bookQuotes.length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedBook = book),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.goldColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(Icons.menu_book,
                                      color: AppTheme.goldColor, size: 24),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${chapters.length} ${chapters.length == 1 ? "capitol" : "capitole"} · $verseCount ${verseCount == 1 ? "verset" : "versete"}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppTheme.goldColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookView(List<BibleQuote> quotes, String book) {
    final bookQuotes = _getBookQuotes(quotes, book);
    final chapters = _getChapters(bookQuotes);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final chapterQuotes =
            bookQuotes.where((q) => q.capitol == chapter).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Capitolul $chapter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),

              // Verses
              ...chapterQuotes.map(
                (quote) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${quote.capitol}:${quote.verset}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          quote.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.7,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (index < chapters.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppTheme.goldColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
