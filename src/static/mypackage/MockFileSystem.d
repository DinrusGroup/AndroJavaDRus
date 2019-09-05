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
import java.nio.file.FileStore;
import java.nio.file.FileSystem;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.nio.file.WatchService;
import java.nio.file.attribute.UserPrincipalLookupService;
import java.nio.file.spi.FileSystemProvider;
import java.util.Map;
import java.util.Set;

public class MockFileSystem : FileSystem {
    private URI uri;
    private Map<String, ?> env;
    private Path path;

    public MockFileSystem(URI uri, Map<String, ?> env) {
        this.uri = uri;
        this.env = env;
    }

    public MockFileSystem(Path path, Map<String, ?> env) {
        this.path = path;
        this.env = env;
    }

    public URI getURI() {
        return uri;
    }

    public Path getPath() {
        return path;
    }

    public Map<String, ?> getEnv() {
        return env;
    }

    override
    public FileSystemProvider provider() {
        return null;
    }

    override
    public void close() throws IOException {

    }

    override
    public bool isOpen() {
        return false;
    }

    override
    public bool isReadOnly() {
        return false;
    }

    override
    public String getSeparator() {
        return null;
    }

    override
    public Iterable<Path> getRootDirectories() {
        return null;
    }

    override
    public Iterable<FileStore> getFileStores() {
        return null;
    }

    override
    public Set<String> supportedFileAttributeViews() {
        return null;
    }

    override
    public Path getPath(String first, String... more) {
        return null;
    }

    override
    public PathMatcher getPathMatcher(String syntaxAndPattern) {
        return null;
    }

    override
    public UserPrincipalLookupService getUserPrincipalLookupService() {
        return null;
    }

    override
    public WatchService newWatchService() throws IOException {
        return null;
    }
}
