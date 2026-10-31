import 'package:mv_app/data/models/video_submission.dart';

final DateTime _now = DateTime.now();

final List<VideoSubmission> mockVideos = [
  VideoSubmission(
    id: 'vid_1',
    title: 'Harvest Festival Highlights 2025',
    submittedBy: 'Ravi Kumar',
    description:
        'Drone footage and highlights from last year\'s harvest festival.',
    status: VideoStatus.featured,
    views: 4210,
    submittedAt: _now.subtract(const Duration(days: 10)),
  ),
  VideoSubmission(
    id: 'vid_2',
    title: 'How to Apply for a Ration Card',
    submittedBy: 'Panchayat Office',
    description: 'Step-by-step guide for new applicants at the village office.',
    status: VideoStatus.approved,
    views: 1580,
    submittedAt: _now.subtract(const Duration(days: 5)),
  ),
  VideoSubmission(
    id: 'vid_3',
    title: 'Local Cricket Tournament Finals',
    submittedBy: 'Suresh Babu',
    description: 'Match highlights from the inter-village cricket finals.',
    status: VideoStatus.pending,
    views: 0,
    submittedAt: _now.subtract(const Duration(hours: 18)),
  ),
  VideoSubmission(
    id: 'vid_4',
    title: 'Organic Farming Tips from Grandpa',
    submittedBy: 'Lakshmi Amma',
    description:
        'Traditional organic farming techniques passed down generations.',
    status: VideoStatus.approved,
    views: 890,
    submittedAt: _now.subtract(const Duration(days: 2)),
  ),
];
