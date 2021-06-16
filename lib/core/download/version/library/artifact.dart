/*
 * Lilay is a custom Minecraft launcher.
 * Copyright (c) 2021 Dreta
 *
 * Lilay is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later dependency.
 *
 * Lilay is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Lilay.  If not, see <https://www.gnu.org/licenses/>.
 */

/// Represents a Maven artifact.
class Artifact {
  final String groupId;
  final String artifactId;
  final String version;

  Artifact(String artifact)
      : groupId = artifact.split(':')[0],
        artifactId = artifact.split(':')[1],
        version = artifact.split(':')[2];

  /// Get where to download this artifact from a root URL.
  String url(String root) {
    return '$root/${groupId.replaceAll('.', '/')}/$artifactId/$version/$artifactId-$version.jar';
  }

  /// Get the URL of the SHA-1 hash of this artifact from a root URL.
  String urlHash(String root) {
    return '$root/${groupId.replaceAll('.', '/')}/$artifactId/$version/$artifactId-$version.jar.sha1';
  }

  @override
  String toString() {
    return '$groupId:$artifactId:$version';
  }
}
