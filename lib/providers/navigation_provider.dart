import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'training_provider.dart';
import 'warmup_provider.dart';

/// The training pages of the home screen, which link to each other.
enum TrainingPage { warmup, workout, benchmarks, history }

final trainingPageProvider =
    NotifierProvider<TrainingPageNotifier, TrainingPage>(
      TrainingPageNotifier.new,
    );

class TrainingPageNotifier extends Notifier<TrainingPage> {
  @override
  TrainingPage build() {
    // A running workout hides the navigation, so it shows its timer: the
    // start awaits the device, during which another page can be opened.
    ref.listen(workoutProvider.select((workout) => workout.isRunning), (
      _,
      running,
    ) {
      if (running) state = TrainingPage.workout;
    });
    ref.listen(warmupProvider.select((warmup) => warmup.isRunning), (
      _,
      running,
    ) {
      if (running) state = TrainingPage.warmup;
    });
    return TrainingPage.workout;
  }

  void open(TrainingPage page) => state = page;
}
