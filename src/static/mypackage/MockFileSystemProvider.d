/*
 * Copyright (C) 2017 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package mypackage;

import java.io.IOException;
import java.net.URI;
import java.nio.channels.SeekableByteChannel;
import java.nio.file.AccessMode;
import java.nio.file.CopyOption;
import java.nio.file.DirectoryStream;
import java.nio.file.FileStore;
import java.nio.file.FileSystem;
import java.nio.file.LinkOption;
import java.nio.file.OpenOption;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.attribute.FileAttribute;
import java.nio.file.attribute.FileAttributeView;
import java.nio.file.spi.FileSystemProvider;
import java.util.Map;
import java.util.Set;

public class MockFileSystemProvider : FileSystemProvider {

    override
    public String getScheme() {
        return "stubScheme";
    }

    override
    public FileSystem newFileSystem(URI uri, Map<String, ?> env) throws IOException {
        return new MockFileSystem(uri, env);
    }

    override
    public FileSystem newFileSystem(Path path, Map<String, ?> env) throws IOException {
        return new MockFileSystem(path, env);
    }

    override
    public FileSystem getFileSystem(URI uri) {
        return null;
    }

    override
    public Path getPath(URI uri) {
        return null;
    }

    override
    public SeekableByteChannel newByteChannel(Path path, Set<? : OpenOption> options,
            FileAttribute!(T)[] attrs) throws IOException {
        return null;
    }

    override
    public DirectoryStream<Path> newDirectoryStream(Path dir,
            DirectoryStream.Filter<? super Path> filter) throws IOException {
        return null;
    }

    override
    public void createDirectory(Path dir, FileAttribute!(T)[] attrs) throws IOException {

    }

    override
    public void delete(Path path) throws IOException {

    }

    override
    public void copy(Path source, Path target, CopyOption... options) throws IOException {

    }

    override
    public void move(Path source, Path target, CopyOption... options) throws IOException {

    }

    override
    public bool isSameFile(Path path, Path path2) throws IOException {
        return false;
    }

    override
    public bool isHidden(Path path) throws IOException {
        return false;
    }

    override
    public FileStore getFileStore(Path path) throws IOException {
        return null;
    }

    override
    public void checkAccess(Path path, AccessMode... modes) throws IOException {

    }

    override
    public <V : FileAttributeView> V getFileAttributeView(Path path, Class<V> type,
            LinkOption... options) {
        return null;
    }

    override
    public <A : BasicFileAttributes> A readAttributes(Path path, Class<A> type,
            LinkOption... options) throws IOException {
        return null;
    }

    override
    public Map<String, Object> readAttributes(Path path, String attributes,
            LinkOption... options) throws IOException {
        return null;
    }

    override
    public void setAttribute(Path path, String attribute, Object value, LinkOption... options)
            throws IOException {

    }
}
