import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The training pages of the home screen, which link to each other.
enum TrainingPage { workout, benchmarks, history }

final trainingPageProvider =
    NotifierProvider<TrainingPageNotifier, TrainingPage>(
      TrainingPageNotifier.new,
    );

class TrainingPageNotifier extends Notifier<TrainingPage> {
  @override
  TrainingPage build() => TrainingPage.workout;

  void open(TrainingPage page) => state = page;
}
