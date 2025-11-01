# Performance Guide

## Performance Philosophy

BillMint is engineered for zero perceived lag on low-end Android devices. Every interaction should feel instant, even on budget phones with limited RAM and slow processors.

## Key Performance Principles

1. **Const Widgets Everywhere**: Prevent unnecessary rebuilds
2. **Lazy Loading**: Load data on demand
3. **Isolates for Heavy Work**: Keep UI thread free
4. **Batch Database Operations**: Use transactions
5. **Memory Efficiency**: Cache strategically, release promptly
6. **Minimal Animations**: Fast, purposeful transitions only

## Common Causes of Jank

### 1. Widget Rebuilds

**Problem**: Entire widget tree rebuilds on small state changes

**Solution**:
- Use `const` constructors wherever possible
- Split widgets into smaller, focused components
- Use `RepaintBoundary` for expensive widgets
- Use Riverpod selectors to listen to specific fields

**Example:**
```dart
// BAD
Widget build(BuildContext context) {
  final state = ref.watch(invoiceProvider);
  return Column(
    children: [
      Text(state.total),
      ExpensiveWidget(), // Rebuilds when total changes
    ],
  );
}

// GOOD
Widget build(BuildContext context) {
  final total = ref.watch(invoiceProvider.select((s) => s.total));
  return Column(
    children: [
      Text(total),
      const ExpensiveWidget(), // Never rebuilds
    ],
  );
}
```

### 2. Long Lists

**Problem**: Building all list items at once

**Solution**:
- Always use `ListView.builder` or `SliverList`
- Provide stable keys
- Limit item height and complexity
- Use `AutomaticKeepAliveClientMixin` sparingly

**Example:**
```dart
// BAD
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// GOOD
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ItemWidget(key: ValueKey(item.id), item: item);
  },
)
```

### 3. Heavy Computations on UI Thread

**Problem**: PDF generation, CSV export blocking UI

**Solution**:
- Run in isolate
- Show progress indicator
- Return result to main isolate

**Example:**
```dart
Future<Uint8List> generatePdfInIsolate(InvoiceData invoice) async {
  return await compute(_generatePdf, invoice);
}

static Uint8List _generatePdf(InvoiceData invoice) {
  // Heavy PDF generation here
  return pdfBytes;
}
```

### 4. Database Operations

**Problem**: Multiple sequential database calls

**Solution**:
- Use batch operations
- Wrap in transactions
- Index frequently queried columns

**Example:**
```dart
// BAD
for (final customer in customers) {
  await db.insertCustomer(customer);
}

// GOOD
await db.transaction(() async {
  await db.insertCustomersBatch(customers);
});
```

### 5. Image Loading

**Problem**: Large images consuming memory

**Solution**:
- Resize images before storing
- Use `Image.memory` with `cacheWidth` and `cacheHeight`
- Compress images for PDFs

**Example:**
```dart
Image.memory(
  imageBytes,
  cacheWidth: 200,
  cacheHeight: 200,
)
```

### 6. Network Requests

**Problem**: Blocking UI while waiting for API

**Solution**:
- Show skeleton UI immediately
- Load data asynchronously
- Cache results

**Example:**
```dart
// Show skeleton
if (isLoading) {
  return const SkeletonList();
}

// Show real data
return ListView.builder(...);
```

## Profiling

### Flutter DevTools

1. **Start DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

2. **Run app in profile mode:**
```bash
flutter run --profile
```

3. **Open DevTools** and connect to running app

4. **Use Performance tab** to record timeline

5. **Look for:**
   - Frames taking >16ms (60 FPS)
   - Widget build times
   - Shader compilation jank

### Performance Overlay

Enable in app:
```dart
MaterialApp(
  showPerformanceOverlay: true,
  ...
)
```

### Benchmarking

Run performance tests:
```bash
flutter drive --target=test_driver/perf_test.dart --profile
```

## Optimization Checklist

### Development Phase

- [ ] Use `const` for all static widgets
- [ ] Use `ListView.builder` for all lists
- [ ] Provide keys for dynamic list items
- [ ] Split large widget trees into smaller widgets
- [ ] Use `SelectiveListener` with Riverpod
- [ ] Avoid `setState` in large widgets
- [ ] Use `RepaintBoundary` for complex widgets

### Database

- [ ] Index frequently queried columns
- [ ] Use batch inserts/updates
- [ ] Wrap multiple operations in transactions
- [ ] Query only needed columns
- [ ] Use pagination for large datasets
- [ ] Cache recent queries in memory

### Heavy Operations

- [ ] Run PDF generation in isolate
- [ ] Run CSV export in isolate
- [ ] Show progress indicators
- [ ] Provide cancellation option
- [ ] Implement small-file fallback for PDFs

### Assets

- [ ] Compress images before embedding
- [ ] Use SVG for icons
- [ ] Preload fonts at app start
- [ ] Limit logo size in PDFs (max 200KB)

### Animations

- [ ] Limit animation duration (120ms max)
- [ ] Use `AnimatedOpacity` instead of `Opacity`
- [ ] Use `AnimatedContainer` for simple transitions
- [ ] Avoid animating expensive layouts
- [ ] Provide option to disable animations

## Performance Testing

### Manual Testing Checklist

Test on low-end device (2GB RAM, quad-core CPU):

- [ ] App launches in <2 seconds
- [ ] Invoice list scrolls at 60 FPS
- [ ] Search returns results in <500ms
- [ ] Creating invoice feels instant
- [ ] PDF generation completes in <5 seconds
- [ ] CSV export completes in <3 seconds
- [ ] No frame drops during navigation
- [ ] Memory usage stays under 200MB

### Automated Tests

```bash
# Run performance tests
flutter test test/performance/

# Profile specific widget
flutter test --profile test/performance/invoice_list_test.dart
```

### Monitor Memory

```dart
// In debug mode, print memory usage
import 'dart:developer' as developer;

void printMemoryUsage() {
  developer.Service.getVMTimelineMicros().then((timeline) {
    print('Memory: ${timeline.toString()}');
  });
}
```

## Troubleshooting Performance Issues

### App Feels Sluggish

1. Run in profile mode and use DevTools
2. Check for widget rebuilds
3. Verify `const` usage
4. Check list implementation
5. Profile database queries

### Jank During Scrolling

1. Use `ListView.builder`
2. Limit item complexity
3. Add `RepaintBoundary`
4. Reduce item height
5. Remove animations from list items

### Slow PDF Generation

1. Verify running in isolate
2. Compress logo image
3. Limit invoice items displayed
4. Use fallback template for large invoices

### High Memory Usage

1. Check image caching
2. Release large objects after use
3. Limit query result size
4. Clear caches periodically

### Slow Database Queries

1. Add indexes
2. Use EXPLAIN QUERY PLAN
3. Limit result set
4. Use pagination

## Target Metrics

- **App Launch**: <2 seconds
- **Screen Navigation**: <100ms
- **List Scroll**: 60 FPS steady
- **Search Results**: <500ms
- **PDF Generation**: <5 seconds for 20 items
- **CSV Export**: <3 seconds for 100 records
- **Memory Usage**: <200MB typical, <300MB peak
- **APK Size**: <20MB

## Resources

- Flutter Performance Best Practices: https://flutter.dev/docs/perf/rendering/best-practices
- Flutter DevTools: https://flutter.dev/docs/development/tools/devtools/overview
- Dart Isolates: https://dart.dev/guides/language/concurrency
