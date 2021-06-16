/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Dreta
 *
 * Lilay is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Lilay is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Lilay.  If not, see <https://www.gnu.org/licenses/>.
 */

/// [DownloadTask] represents the basic structure for all the
/// downloading in Lilay.
///
/// [D] refers to the type of the **dependency** for this task.
/// Use `void` if no dependencies are required.
///
/// [R} refers to the type of the **result** for this task.
abstract class DownloadTask<D, R> {
  /// Where to download from. You will need to properly replace the default
  /// source with this in [download].
  final String source;

  /// Whether this task has been cancelled.
  bool cancelled = false;

  /// The progress, from `0` to `1` (inclusive).
  double progress = 0;

  /// The exception object received when an error occurred.
  Object? exception;

  /// When the exception object was received.
  Phase? exceptionPhase;

  /// The dependency of this task.
  D dependency;

  /// The result of this task.
  R? result;

  /// The working directory of this task.
  String workingDir;

  /// A list of callbacks to call when properties of this task
  /// changes.
  final List<TaskUpdateCallback> callbacks = [];

  DownloadTask(
      {required this.source,
      required this.dependency,
      required this.workingDir});

  /// Whether this task has been finished.
  bool get finished => progress >= 1;

  /// Notify all the callbacks of changes in this task.
  void notify() {
    if (cancelled) return;
    for (TaskUpdateCallback callback in callbacks) callback();
  }

  /// Try to load the cache of this task, if available.
  ///
  /// Returns `true` if succeeded, or `false` if failed.
  /// The error might be present in [exception] with [exceptionPhase]
  /// [Phase.loadCache] if the return value is `false`.
  /// The result might be available in [result] if the return value is `true`.
  Future<bool> get tryLoadCache;

  /// Attempts to load cache and start this task.
  Future<void> start() async {
    if (await tryLoadCache) {
      notify();
      return;
    }
    download();
  }

  /// Download.
  ///
  /// This method should not be called from other classes unless required.
  Future<void> download();

  /// Cache the downloaded data to the disk.
  Future<void> save();
}

typedef void TaskUpdateCallback();

enum Phase { loadCache, download, save }
