/*
 * Copyright (C) 2022 The Android Open Source Project
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

package android.hardware.audio.core;

import android.media.audio.common.AudioLatencyMode;

/**
 * This interface provides means for asynchronous notification of the client
 * by an output stream.
 */
@VintfStability
oneway interface IStreamOutEventCallback {
    /**
     * Codec format changed notification.
     *
     * onCodecFormatChanged returns an AudioMetadata object in read-only
     * ByteString format.  It represents the most recent codec format decoded by
     * a HW audio decoder.
     *
     * Codec format is an optional message from HW audio decoders. It serves to
     * notify the application about the codec format and audio objects contained
     * within the compressed audio stream for control, informational,
     * and display purposes.
     *
     * audioMetadata ByteString is convertible to an AudioMetadata object
     * through both a C++ and a C API present in Metadata.h [1], or through a
     * Java API present in AudioMetadata.java [2].
     *
     * The ByteString format is a stable format used for parcelling
     * (marshalling) across JNI, AIDL, and HIDL interfaces.  The test for R
     * compatibility for native marshalling is TEST(metadata_tests,
     * compatibility_R) [3]. The test for R compatibility for JNI marshalling
     * is android.media.cts.AudioMetadataTest#testCompatibilityR [4].
     *
     * Android R defined keys are as follows [2]:
     * "bitrate", int32
     * "channel-mask", int32
     * "mime", string
     * "sample-rate", int32
     * "bit-width", int32
     * "has-atmos", int32
     * "audio-encoding", int32
     *
     * Android S in addition adds the following keys:
     * "presentation-id", int32
     * "program-id", int32
     * "presentation-content-classifier", int32
     *    presentation-content-classifier key values can be referenced from
     *    frameworks/base/media/java/android/media/AudioPresentation.java
     *    i.e. AudioPresentation.ContentClassifier
     *    It can contain any of the below values
     *    CONTENT_UNKNOWN   = -1,
     *    CONTENT_MAIN      =  0,
     *    CONTENT_MUSIC_AND_EFFECTS = 1,
     *    CONTENT_VISUALLY_IMPAIRED = 2,
     *    CONTENT_HEARING_IMPAIRED  = 3,
     *    CONTENT_DIALOG = 4,
     *    CONTENT_COMMENTARY = 5,
     *    CONTENT_EMERGENCY = 6,
     *    CONTENT_VOICEOVER = 7
     * "presentation-language", string  // represents ISO 639-2 (three letter code)
     *
     * Parceling Format:
     * All values are native endian order. [1]
     *
     * using type_size_t = uint32_t;
     * using index_size_t = uint32_t;
     * using datum_size_t = uint32_t;
     *
     * Permitted type indexes are
     * TYPE_NONE = 0, // Reserved
     * TYPE_INT32 = 1,
     * TYPE_INT64 = 2,
     * TYPE_FLOAT = 3,
     * TYPE_DOUBLE = 4,
     * TYPE_STRING = 5,
     * TYPE_DATA = 6,  // A data table of <String, Datum>
     *
     * Datum = {
     *           (type_size_t)  Type (the type index from type_as_value<T>.)
     *           (datum_size_t) Size (size of the Payload)
     *           (byte string)  Payload<Type>
     *         }
     *
     * The data is specified in native endian order. Since the size of the
     * Payload is always present, unknown types may be skipped.
     *
     * Payload<Fixed-size Primitive_Value>
     * [ sizeof(Primitive_Value) in raw bytes ]
     *
     * Example of Payload<Int32> of 123:
     * Payload<Int32>
     * [ value of 123                   ] =  0x7b 0x00 0x00 0x00       123
     *
     * Payload<String>
     * [ (index_size_t) length, not including zero terminator.]
     * [ (length) raw bytes ]
     *
     * Example of Payload<String> of std::string("hi"):
     * [ (index_size_t) length          ] = 0x02 0x00 0x00 0x00        2 strlen("hi")
     * [ raw bytes "hi"                 ] = 0x68 0x69                  "hi"
     *
     * Payload<Data>
     * [ (index_size_t) entries ]
     * [ raw bytes   (entry 1) Key   (Payload<String>)
     *                         Value (Datum)
     *                ...  (until #entries) ]
     *
     * Example of Payload<Data> of {{"hello", "world"},
     *                              {"value", (int32_t)1000}};
     * [ (index_size_t) #entries        ] = 0x02 0x00 0x00 0x00        2 entries
     *    Key (Payload<String>)
     *    [ index_size_t length         ] = 0x05 0x00 0x00 0x00        5 strlen("hello")
     *    [ raw bytes "hello"           ] = 0x68 0x65 0x6c 0x6c 0x6f   "hello"
     *    Value (Datum)
     *    [ (type_size_t) type          ] = 0x05 0x00 0x00 0x00        5 (TYPE_STRING)
     *    [ (datum_size_t) size         ] = 0x09 0x00 0x00 0x00        sizeof(index_size_t) +
     *                                                                 strlen("world")
     *       Payload<String>
     *       [ (index_size_t) length    ] = 0x05 0x00 0x00 0x00        5 strlen("world")
     *       [ raw bytes "world"        ] = 0x77 0x6f 0x72 0x6c 0x64   "world"
     *    Key (Payload<String>)
     *    [ index_size_t length         ] = 0x05 0x00 0x00 0x00        5 strlen("value")
     *    [ raw bytes "value"           ] = 0x76 0x61 0x6c 0x75 0x65   "value"
     *    Value (Datum)
     *    [ (type_size_t) type          ] = 0x01 0x00 0x00 0x00        1 (TYPE_INT32)
     *    [ (datum_size_t) size         ] = 0x04 0x00 0x00 0x00        4 sizeof(int32_t)
     *        Payload<Int32>
     *        [ raw bytes 1000          ] = 0xe8 0x03 0x00 0x00        1000
     *
     * The contents of audioMetadata is a Payload<Data>.
     * An implementation dependent detail is that the Keys are always
     * stored sorted, so the byte string representation generated is unique.
     *
     * Vendor keys are allowed for informational and debugging purposes.
     * Vendor keys should consist of the vendor company name followed
     * by a dot; for example, "vendorCompany.someVolume" [2].
     *
     * [1] system/media/audio_utils/include/audio_utils/Metadata.h
     * [2] frameworks/base/media/java/android/media/AudioMetadata.java
     * [3] system/media/audio_utils/tests/metadata_tests.cpp
     * [4] cts/tests/tests/media/src/android/media/cts/AudioMetadataTest.java
     *
     * @param audioMetadata A buffer containing decoded format changes
     *     reported by codec. The buffer contains data that can be transformed
     *     to audio metadata, which is a C++ object based map.
     */
    void onCodecFormatChanged(in byte[] audioMetadata);

    /**
     * Called with the new list of supported latency modes when a change occurs.
     */
    void onRecommendedLatencyModeChanged(in AudioLatencyMode[] modes);
}
