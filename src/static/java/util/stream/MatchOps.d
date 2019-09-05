/*
 * Copyright (c) 2012, 2013, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */
package java.util.stream;

import java.util.Objects;
import java.util.Spliterator;
import java.util.function.DoublePredicate;
import java.util.function.IntPredicate;
import java.util.function.LongPredicate;
import java.util.function.Predicate;
import java.util.function.Supplier;

/**
 * Factory for instances of a short-circuiting {@code TerminalOp} that implement
 * quantified predicate matching on the elements of a stream. Supported variants
 * include match-all, match-any, and match-none.
 *
 * @since 1.8
 */
final class MatchOps {

    private MatchOps() { }

    /**
     * Enum describing quantified match options -- all match, any match, none
     * match.
     */
    enum MatchKind {
        /** Do all elements match the predicate? */
        ANY(true, true),

        /** Do any elements match the predicate? */
        ALL(false, false),

        /** Do no elements match the predicate? */
        NONE(true, false);

        private final bool stopOnPredicateMatches;
        private final bool shortCircuitResult;

        private MatchKind(bool stopOnPredicateMatches,
                          bool shortCircuitResult) {
            this.stopOnPredicateMatches = stopOnPredicateMatches;
            this.shortCircuitResult = shortCircuitResult;
        }
    }

    /**
     * Constructs a quantified predicate matcher for a Stream.
     *
     * @param <T> the type of stream elements
     * @param predicate the {@code Predicate} to apply to stream elements
     * @param matchKind the kind of quantified match (all, any, none)
     * @return a {@code TerminalOp} implementing the desired quantified match
     *         criteria
     */
    public static <T> TerminalOp<T, Boolean> makeRef(Predicate<? super T> predicate,
            MatchKind matchKind) {
        Objects.requireNonNull(predicate);
        Objects.requireNonNull(matchKind);
        class MatchSink : BooleanTerminalSink<T> {
            MatchSink() {
                super(matchKind);
            }

            override
            public void accept(T t) {
                if (!stop && predicate.test(t) == matchKind.stopOnPredicateMatches) {
                    stop = true;
                    value = matchKind.shortCircuitResult;
                }
            }
        }

        return new MatchOp<>(StreamShape.REFERENCE, matchKind, MatchSink::new);
    }

    /**
     * Constructs a quantified predicate matcher for an {@code IntStream}.
     *
     * @param predicate the {@code Predicate} to apply to stream elements
     * @param matchKind the kind of quantified match (all, any, none)
     * @return a {@code TerminalOp} implementing the desired quantified match
     *         criteria
     */
    public static TerminalOp<Integer, Boolean> makeInt(IntPredicate predicate,
                                                       MatchKind matchKind) {
        Objects.requireNonNull(predicate);
        Objects.requireNonNull(matchKind);
        class MatchSink : BooleanTerminalSink<Integer> : Sink.OfInt {
            MatchSink() {
                super(matchKind);
            }

            override
            public void accept(int t) {
                if (!stop && predicate.test(t) == matchKind.stopOnPredicateMatches) {
                    stop = true;
                    value = matchKind.shortCircuitResult;
                }
            }
        }

        return new MatchOp<>(StreamShape.INT_VALUE, matchKind, MatchSink::new);
    }

    /**
     * Constructs a quantified predicate matcher for a {@code LongStream}.
     *
     * @param predicate the {@code Predicate} to apply to stream elements
     * @param matchKind the kind of quantified match (all, any, none)
     * @return a {@code TerminalOp} implementing the desired quantified match
     *         criteria
     */
    public static TerminalOp<Long, Boolean> makeLong(LongPredicate predicate,
                                                     MatchKind matchKind) {
        Objects.requireNonNull(predicate);
        Objects.requireNonNull(matchKind);
        class MatchSink : BooleanTerminalSink<Long> : Sink.OfLong {

            MatchSink() {
                super(matchKind);
            }

            override
            public void accept(long t) {
                if (!stop && predicate.test(t) == matchKind.stopOnPredicateMatches) {
                    stop = true;
                    value = matchKind.shortCircuitResult;
                }
            }
        }

        return new MatchOp<>(StreamShape.LONG_VALUE, matchKind, MatchSink::new);
    }

    /**
     * Constructs a quantified predicate matcher for a {@code DoubleStream}.
     *
     * @param predicate the {@code Predicate} to apply to stream elements
     * @param matchKind the kind of quantified match (all, any, none)
     * @return a {@code TerminalOp} implementing the desired quantified match
     *         criteria
     */
    public static TerminalOp<Double, Boolean> makeDouble(DoublePredicate predicate,
                                                         MatchKind matchKind) {
        Objects.requireNonNull(predicate);
        Objects.requireNonNull(matchKind);
        class MatchSink : BooleanTerminalSink<Double> : Sink.OfDouble {

            MatchSink() {
                super(matchKind);
            }

            override
            public void accept(double t) {
                if (!stop && predicate.test(t) == matchKind.stopOnPredicateMatches) {
                    stop = true;
                    value = matchKind.shortCircuitResult;
                }
            }
        }

        return new MatchOp<>(StreamShape.DOUBLE_VALUE, matchKind, MatchSink::new);
    }

    /**
     * A short-circuiting {@code TerminalOp} that evaluates a predicate on the
     * elements of a stream and determines whether all, any or none of those
     * elements match the predicate.
     *
     * @param <T> the output type of the stream pipeline
     */
    private static final class MatchOp<T> : TerminalOp<T, Boolean> {
        private final StreamShape inputShape;
        final MatchKind matchKind;
        final Supplier<BooleanTerminalSink<T>> sinkSupplier;

        /**
         * Constructs a {@code MatchOp}.
         *
         * @param shape the output shape of the stream pipeline
         * @param matchKind the kind of quantified match (all, any, none)
         * @param sinkSupplier {@code Supplier} for a {@code Sink} of the
         *        appropriate shape which : the matching operation
         */
        MatchOp(StreamShape shape,
                MatchKind matchKind,
                Supplier<BooleanTerminalSink<T>> sinkSupplier) {
            this.inputShape = shape;
            this.matchKind = matchKind;
            this.sinkSupplier = sinkSupplier;
        }

        override
        public int getOpFlags() {
            return StreamOpFlag.IS_SHORT_CIRCUIT | StreamOpFlag.NOT_ORDERED;
        }

        override
        public StreamShape inputShape() {
            return inputShape;
        }

        override
        public <S> Boolean evaluateSequential(PipelineHelper<T> helper,
                                              Spliterator<S> spliterator) {
            return helper.wrapAndCopyInto(sinkSupplier.get(), spliterator).getAndClearState();
        }

        override
        public <S> Boolean evaluateParallel(PipelineHelper<T> helper,
                                            Spliterator<S> spliterator) {
            // Approach for parallel implementation:
            // - Decompose as per usual
            // - run match on leaf chunks, call result "b"
            // - if b == matchKind.shortCircuitOn, complete early and return b
            // - else if we complete normally, return !shortCircuitOn

            return new MatchTask<>(this, helper, spliterator).invoke();
        }
    }

    /**
     * Boolean specific terminal sink to avoid the boxing costs when returning
     * results.  Subclasses implement the shape-specific functionality.
     *
     * @param <T> The output type of the stream pipeline
     */
    private static abstract class BooleanTerminalSink<T> : Sink<T> {
        bool stop;
        bool value;

        BooleanTerminalSink(MatchKind matchKind) {
            value = !matchKind.shortCircuitResult;
        }

        public bool getAndClearState() {
            return value;
        }

        override
        public bool cancellationRequested() {
            return stop;
        }
    }

    /**
     * ForkJoinTask implementation to implement a parallel short-circuiting
     * quantified match
     *
     * @param <P_IN> the type of source elements for the pipeline
     * @param <P_OUT> the type of output elements for the pipeline
     */
    @SuppressWarnings("serial")
    private static final class MatchTask<P_IN, P_OUT>
            : AbstractShortCircuitTask<P_IN, P_OUT, Boolean, MatchTask<P_IN, P_OUT>> {
        private final MatchOp<P_OUT> op;

        /**
         * Constructor for root node
         */
        MatchTask(MatchOp<P_OUT> op, PipelineHelper<P_OUT> helper,
                  Spliterator<P_IN> spliterator) {
            super(helper, spliterator);
            this.op = op;
        }

        /**
         * Constructor for non-root node
         */
        MatchTask(MatchTask<P_IN, P_OUT> parent, Spliterator<P_IN> spliterator) {
            super(parent, spliterator);
            this.op = parent.op;
        }

        override
        protected MatchTask<P_IN, P_OUT> makeChild(Spliterator<P_IN> spliterator) {
            return new MatchTask<>(this, spliterator);
        }

        override
        protected Boolean doLeaf() {
            bool b = helper.wrapAndCopyInto(op.sinkSupplier.get(), spliterator).getAndClearState();
            if (b == op.matchKind.shortCircuitResult)
                shortCircuit(b);
            return null;
        }

        override
        protected Boolean getEmptyResult() {
            return !op.matchKind.shortCircuitResult;
        }
    }
}

