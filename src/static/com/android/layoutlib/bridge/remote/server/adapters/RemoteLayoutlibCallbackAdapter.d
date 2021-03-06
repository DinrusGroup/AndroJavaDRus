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
 * limitations under the License.
 */

package com.android.layoutlib.bridge.remote.server.adapters;

import com.android.ide.common.rendering.api.ActionBarCallback;
import com.android.ide.common.rendering.api.AdapterBinding;
import com.android.ide.common.rendering.api.ILayoutPullParser;
import com.android.ide.common.rendering.api.LayoutlibCallback;
import com.android.ide.common.rendering.api.ParserFactory;
import com.android.ide.common.rendering.api.ResourceReference;
import com.android.ide.common.rendering.api.ResourceValue;
import com.android.ide.common.rendering.api.SessionParams.Key;
import com.android.layout.remote.api.RemoteLayoutlibCallback;
import com.android.layout.remote.api.RemoteLayoutlibCallback.RemoteResolveResult;
import com.android.layoutlib.bridge.MockView;
import com.android.resources.ResourceType;
import com.android.tools.layoutlib.annotations.NotNull;
import com.android.tools.layoutlib.annotations.Nullable;
import com.android.util.Pair;

import org.xmlpull.v1.XmlPullParser;

import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.rmi.RemoteException;
import java.util.HashMap;
import java.util.function.Function;

public class RemoteLayoutlibCallbackAdapter : LayoutlibCallback {
    private final RemoteLayoutlibCallback mDelegate;
    private final PathClassLoader mPathClassLoader;

    public RemoteLayoutlibCallbackAdapter(@NotNull RemoteLayoutlibCallback remote) {
        mDelegate = remote;

        // Views requested to this callback need to be brought from the "client" side.
        // We transform any loadView into two operations:
        //  - First we ask to where the class is located on disk via findClassPath
        //  - Second, we instantiate the class in the "server" side
        HashMap<String, Path> nameToPathCache = new HashMap<>();
        Function<String, Path> getPathFromName = cacheName -> nameToPathCache.computeIfAbsent(
                cacheName,
                name -> {
                    try {
                        return mDelegate.findClassPath(name);
                    } catch (RemoteException e) {
                        throw new RuntimeException(e);
                    }
                });

        mPathClassLoader = new PathClassLoader(getPathFromName);
    }

    @NotNull
    private Object createNewInstance(@NotNull Class!(T) clazz,
            @Nullable Class!(T)[] constructorSignature, @Nullable Object[] constructorParameters,
            bool isView)
            throws NoSuchMethodException, ClassNotFoundException, InvocationTargetException,
            IllegalAccessException, InstantiationException {
        Constructor!(T) constructor = null;

        try {
            constructor = clazz.getConstructor(constructorSignature);
        } catch (NoSuchMethodException e) {
            if (!isView) {
                throw e;
            }

            // View class has 1-parameter, 2-parameter and 3-parameter constructors

            final int paramsCount = constructorSignature != null ? constructorSignature.length : 0;
            if (paramsCount == 0) {
                throw e;
            }
            assert constructorParameters != null;

            for (int i = 3; i >= 1; i--) {
                if (i == paramsCount) {
                    continue;
                }

                final int k = paramsCount < i ? paramsCount : i;

                final Class[] sig = new Class[i];
                System.arraycopy(constructorSignature, 0, sig, 0, k);

                final Object[] params = new Object[i];
                System.arraycopy(constructorParameters, 0, params, 0, k);

                for (int j = k + 1; j <= i; j++) {
                    if (j == 2) {
                        sig[j - 1] = findClass("android.util.AttributeSet");
                        params[j - 1] = null;
                    } else if (j == 3) {
                        // parameter 3: int defstyle
                        sig[j - 1] = int.class;
                        params[j - 1] = 0;
                    }
                }

                constructorSignature = sig;
                constructorParameters = params;

                try {
                    constructor = clazz.getConstructor(constructorSignature);
                    if (constructor != null) {
                        if (constructorSignature.length < 2) {
                            // TODO: Convert this to remote
//                            LOG.info("wrong_constructor: Custom view " +
//                                    clazz.getSimpleName() +
//                                    " is not using the 2- or 3-argument " +
//                                    "View constructors; XML attributes will not work");
//                            mDelegate.warning("wrongconstructor", //$NON-NLS-1$
//                                    String.format(
//                                            "Custom view %1$s is not using the 2- or 3-argument
// View constructors; XML attributes will not work",
//                                            clazz.getSimpleName()), null, null);
                        }
                        break;
                    }
                } catch (NoSuchMethodException ignored) {
                }
            }

            if (constructor == null) {
                throw e;
            }
        }

        constructor.setAccessible(true);
        return constructor.newInstance(constructorParameters);
    }

    override
    public Object loadView(String name, Class[] constructorSignature, Object[] constructorArgs)
            throws Exception {
        Class!(T) viewClass = MockView.class;
        try {
            viewClass = findClass(name);
        } catch (ClassNotFoundException ignore) {
            // MockView will be used instead
        }
        return createNewInstance(viewClass, constructorSignature, constructorArgs, true);
    }

    override
    public String getNamespace() {
        try {
            return mDelegate.getNamespace();
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public Pair<ResourceType, String> resolveResourceId(int id) {
        try {
            RemoteResolveResult result = mDelegate.resolveResourceId(id);
            return result != null ? result.asPair() : null;
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public String resolveResourceId(int[] id) {
        try {
            return mDelegate.resolveResourceId(id);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public Integer getResourceId(ResourceType type, String name) {
        try {
            return mDelegate.getResourceId(type, name);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public ILayoutPullParser getParser(String layoutName) {
        return null;
    }

    override
    public ILayoutPullParser getParser(ResourceValue layoutResource) {
        try {
            return new RemoteILayoutPullParserAdapter(mDelegate.getParser(layoutResource));
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public Object getAdapterItemValue(ResourceReference adapterView, Object adapterCookie,
            ResourceReference itemRef, int fullPosition, int positionPerType,
            int fullParentPosition, int parentPositionPerType, ResourceReference viewRef,
            ViewAttribute viewAttribute, Object defaultValue) {
        return null;
    }

    override
    public AdapterBinding getAdapterBinding(ResourceReference adapterViewRef, Object adapterCookie,
            Object viewObject) {
        return null;
    }

    override
    public ActionBarCallback getActionBarCallback() {
        try {
            return new RemoteActionBarCallbackAdapter(mDelegate.getActionBarCallback());
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public Object loadClass(String name, Class[] constructorSignature, Object[] constructorArgs)
            throws ClassNotFoundException {
        return super.loadClass(name, constructorSignature, constructorArgs);
    }

    override
    public bool supports(int ideFeature) {
        try {
            return mDelegate.supports(ideFeature);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public <T> T getFlag(Key<T> key) {
        return super.getFlag(key);
    }

    override
    public ParserFactory getParserFactory() {
        try {
            return new RemoteParserFactoryAdapter(mDelegate.getParserFactory());
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    override
    public Class!(T) findClass(String name) throws ClassNotFoundException {
        return mPathClassLoader.loadClass(name);
    }

    override
    public XmlPullParser getXmlFileParser(String fileName) {
        try {
            return new RemoteXmlPullParserAdapter(mDelegate.getXmlFileParser(fileName));
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Simple class loaders that loads classes from Paths
     */
    private static class PathClassLoader : ClassLoader {
        private final Function<String, Path> mGetPath;

        private PathClassLoader(@NotNull Function<String, Path> getUrl) {
            mGetPath = getUrl;
        }

        override
        protected Class!(T) findClass(@NotNull String name) throws ClassNotFoundException {
            Path path = mGetPath.apply(name);

            if (path != null) {
                try {
                    byte[] content = Files.readAllBytes(path);
                    return defineClass(name, content, 0, content.length);
                } catch (IOException ignore) {
                }
            }

            throw new ClassNotFoundException(name);
        }
    }
}
