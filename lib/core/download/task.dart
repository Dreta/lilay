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

abstract class DownloadTask<D, R> {
  final String source;
  bool cancelled = false;

  double progress = 0;
  Object? exception;
  Phase? exceptionPhase;
  D dependency;
  R? result;
  String workingDir;

  final List<TaskUpdateCallback> callbacks = [];

  DownloadTask(
      {required this.source,
      required this.dependency,
      required this.workingDir});

  bool get finished => progress >= 1;

  void notify() {
    for (TaskUpdateCallback callback in callbacks) callback();
  }

  Future<bool> get cacheAvailable;

  Future<void> start() async {
    if (await cacheAvailable) return;
    download();
  }

  // This method should NOT be accessed by other classes!
  Future<void> download();

  Future<void> save();
}

typedef void TaskUpdateCallback();

enum Phase { loadCache, download, save }
