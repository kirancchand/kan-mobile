import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mv_app/core/services/media_picker.dart';
import 'package:mv_app/core/widgets/media_attachments.dart';
import 'package:mv_app/core/theme/app_theme.dart';
import 'package:mv_app/data/models/media_attachment.dart';
import 'package:mv_app/data/models/service_type.dart';
import 'package:mv_app/data/repositories/auth_repository.dart';
import 'package:mv_app/data/repositories/whatsapp_group_repository.dart';
import 'package:mv_app/data/repositories/marketplace_repository.dart';
import 'package:mv_app/data/repositories/book_repository.dart';
import 'package:mv_app/data/repositories/ride_repository.dart';
import 'package:mv_app/data/repositories/video_repository.dart';
import 'package:mv_app/data/repositories/delivery_repository.dart';
import 'package:mv_app/features/services/marketplace/marketplace_post_screen.dart';
import 'package:mv_app/features/services/library/post_book_screen.dart';
import 'package:mv_app/features/services/ride_pool/post_ride_screen.dart';
import 'package:mv_app/features/services/youtube/submit_video_screen.dart';
import 'package:mv_app/features/services/delivery/request_delivery_screen.dart';
import 'package:mv_app/state/app_state.dart';

final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=');

class _Files extends FileSelectorPlatform {
  XFile? result;
  Completer<XFile?>? pending;
  @override
  Future<XFile?> openFile(
          {List<XTypeGroup>? acceptedTypeGroups,
          String? initialDirectory,
          String? confirmButtonText}) async =>
      pending != null ? await pending!.future : result;
}

void main() {
  late _Files files;
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    final original = FileSelectorPlatform.instance;
    files = _Files();
    FileSelectorPlatform.instance = files;
    addTearDown(() => FileSelectorPlatform.instance = original);
  });

  test(
      'Picker rejects empty, oversized and unsupported files and total overflow',
      () async {
    final picker = MediaPicker();
    for (final file in [
      XFile.fromData(Uint8List(0), name: 'empty.png', path: 'empty.png'),
      XFile.fromData(Uint8List(MediaPicker.maxFileBytes + 1),
          name: 'large.mp4', path: 'large.mp4'),
      XFile.fromData(Uint8List(1), name: 'document.pdf', path: 'document.pdf'),
    ]) {
      await expectLater(
          picker.readFile(file,
              file.name.endsWith('mp4') ? MediaKind.video : MediaKind.image,
              remainingBytes: MediaPicker.maxTotalBytes),
          throwsFormatException);
    }
    await expectLater(
        picker.readFile(
            XFile.fromData(_png, name: 'photo.png', path: 'photo.png'),
            MediaKind.image,
            remainingBytes: 1),
        throwsFormatException);
    final item = await picker.readFile(
        XFile.fromData(_png, name: 'photo.PNG', path: 'photo.PNG'),
        MediaKind.image,
        remainingBytes: MediaPicker.maxTotalBytes);
    expect(item.bytes, _png);
    expect(() => item.bytes[0] = 0, throwsUnsupportedError);
  });

  testWidgets(
      'Selection supports cancel, removal, limits, errors and busy state',
      (tester) async {
    var selected = <MediaAttachment>[];
    var busy = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: StatefulBuilder(
          builder: (context, setState) => MediaAttachmentField(
                attachments: selected,
                onChanged: (value) => setState(() => selected = value),
                onBusyChanged: (value) => busy = value,
              )),
    ))));
    await tester.tap(find.text('Add image'));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    files.pending = Completer<XFile?>();
    await tester.tap(find.text('Add video'));
    await tester.pump();
    expect(busy, isTrue);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Add image'))
            .onPressed,
        isNull);
    files.pending!.complete(XFile.fromData(Uint8List.fromList([1, 2, 3]),
        name: 'clip.mp4', path: 'clip.mp4'));
    await tester.pumpAndSettle();
    files.pending = null;
    expect(selected.single.kind, MediaKind.video);
    expect(busy, isFalse);
    await tester.tap(find.byTooltip('Remove clip.mp4'));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    files.result =
        XFile.fromData(Uint8List(0), name: 'empty.png', path: 'empty.png');
    await tester.tap(find.text('Add image'));
    await tester.pumpAndSettle();
    expect(find.text('This file is empty.'), findsOneWidget);
    files.result = XFile.fromData(_png, name: 'photo.png', path: 'photo.png');
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Add image'));
      await tester.pumpAndSettle();
    }
    expect(selected.length, 5);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Add video'))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });

  for (final type in ServiceType.values) {
    testWidgets(
        '${type.label} submits selected images and videos with its entry',
        (tester) async {
      final marketplace = MarketplaceRepository();
      final books = BookRepository();
      final rides = RideRepository();
      final videos = VideoRepository();
      final deliveries = DeliveryRepository();
      addTearDown(() {
        marketplace.dispose();
        books.dispose();
        rides.dispose();
        videos.dispose();
        deliveries.dispose();
      });
      final groups = WhatsAppGroupRepository();
      final form = switch (type) {
        ServiceType.library => const PostBookScreen(),
        ServiceType.ridePool => const PostRideScreen(),
        ServiceType.youtube => const SubmitVideoScreen(),
        ServiceType.delivery => const RequestDeliveryScreen(),
        _ => MarketplacePostScreen(serviceType: type),
      };
      final values = switch (type) {
        ServiceType.library => ['Media book', 'Author', 'Fiction', '25'],
        ServiceType.ridePool => ['Village', 'Town', '2', '30', 'Blue car'],
        ServiceType.youtube => ['Media video', 'Village story', ''],
        ServiceType.delivery => ['Media parcel', 'Village', 'Town'],
        _ => ['Media item', 'Description', 'General', '50'],
      };
      final submit = switch (type) {
        ServiceType.library => 'List Book',
        ServiceType.ridePool => 'Post Ride',
        ServiceType.youtube => 'Submit for Review',
        ServiceType.delivery => 'Request Delivery',
        _ => 'Post Listing',
      };
      await tester.pumpWidget(MultiProvider(
          providers: [
            Provider.value(value: marketplace),
            Provider.value(value: books),
            Provider.value(value: rides),
            Provider.value(value: videos),
            Provider.value(value: deliveries),
            ChangeNotifierProvider(
                create: (_) => AppState(
                    whatsAppGroupRepository: groups,
                    authRepository: AuthRepository(groups))),
          ],
          child: MaterialApp(
              theme: AppTheme.light,
              home: Builder(
                  builder: (context) => Scaffold(
                        body: TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute<void>(builder: (_) => form)),
                            child: const Text('Open form')),
                      )))));
      await tester.tap(find.text('Open form'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      for (var i = 0; i < values.length; i++) {
        await tester.enterText(fields.at(i), values[i]);
      }
      files.result = XFile.fromData(_png, name: 'photo.png', path: 'photo.png');
      await tester.ensureVisible(find.text('Add image'));
      await tester.tap(find.text('Add image'));
      await tester.pumpAndSettle();
      files.result = XFile.fromData(Uint8List.fromList([1, 2, 3]),
          name: 'clip.mp4', path: 'clip.mp4');
      await tester.ensureVisible(find.text('Add video'));
      await tester.tap(find.text('Add video'));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, submit);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Open form'), findsOneWidget);
      final List<MediaAttachment> saved = await tester.runAsync(() async {
            return switch (type) {
              ServiceType.library => (await books.getBooks()).first.attachments,
              ServiceType.ridePool => (await rides.getRides())
                  .firstWhere((r) => r.from == 'Village')
                  .attachments,
              ServiceType.youtube =>
                (await videos.getVideos()).first.attachments,
              ServiceType.delivery =>
                (await deliveries.getOrders()).first.attachments,
              _ => (await marketplace.getListings(type)).first.attachments,
            };
          }) ??
          [];
      expect(saved.map((a) => a.name), ['photo.png', 'clip.mp4']);
      expect(saved.first.bytes, _png);
      expect(() => saved.clear(), throwsUnsupportedError);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
