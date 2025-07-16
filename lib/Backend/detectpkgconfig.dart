// Hardcoded metadata: library -> { includes: [...], pkg-config: string/null, windows: string }
const Map<String, Map<String, dynamic>> libraries = {
  "OpenGL":          { "includes": ["<GL/gl.h>", "<GL/glu.h>"],               "pkg-config": "gl",         "windows": "opengl32 (Windows SDK)" },
  "GLU":             { "includes": ["<GL/glu.h>"],                          "pkg-config": "glu",        "windows": "glu32.lib (Windows SDK)" },
  "GLEW":            { "includes": ["<GL/glew.h>"],                         "pkg-config": "glew",       "windows": "glew (vcpkg: glew)" },
  "GLFW":            { "includes": ["<GLFW/glfw3.h>"],                      "pkg-config": "glfw3",      "windows": "glfw3 (vcpkg: glfw3)" },
  "FreeGLUT":        { "includes": ["<GL/freeglut.h>"],                     "pkg-config": "glut",       "windows": "freeglut (vcpkg: freeglut)" },
  "SDL2":            { "includes": ["<SDL2/SDL.h>"],                        "pkg-config": "sdl2",       "windows": "sdl2 (vcpkg: sdl2)" },
  "SFML":            { "includes": ["<SFML/Graphics.hpp>", "<SFML/Window.hpp>"], "pkg-config": "sfml-all",   "windows": "sfml (vcpkg: sfml[all])" },
  "Cairo":           { "includes": ["<cairo.h>"],                            "pkg-config": "cairo",      "windows": "cairo (vcpkg: cairo)" },
  "Skia":            { "includes": ["<SkSurface.h>", "<SkCanvas.h>"],           "pkg-config": "skia",       "windows": "skia (manual build)" },
  "Allegro5":        { "includes": ["<allegro5/allegro.h>"],                  "pkg-config": "allegro-5",  "windows": "allegro5 (vcpkg: allegro5)" },
  "NanoVG":          { "includes": ["<nanovg.h>"],                           "pkg-config": null,          "windows": "nanovg (header-only)" },
  "OpenSceneGraph":  { "includes": ["<osg/Node>"],                            "pkg-config": "openscenegraph", "windows": "openscenegraph (vcpkg: openscenegraph)" },
  "OGRE":            { "includes": ["<OGRE/Ogre.h>"],                        "pkg-config": "OGRE",       "windows": "ogre (vcpkg: ogre)" },
  "OpenVDB":         { "includes": ["<openvdb/openvdb.h>"],                  "pkg-config": "openvdb",    "windows": "openvdb (vcpkg: openvdb)" },

  "OpenCV":          { "includes": ["<opencv2/opencv.hpp>", "<opencv2/core.hpp>"], "pkg-config": "opencv4",   "windows": "opencv4 (vcpkg: opencv4)" },
  "Dlib":            { "includes": ["<dlib/dlib.h>"],                         "pkg-config": null,          "windows": "dlib (vcpkg: dlib)" },
  "Halide":          { "includes": ["<Halide.h>"],                            "pkg-config": null,          "windows": "halide (vcpkg: halide)" },
  "PCL":             { "includes": ["<pcl/point_types.h>"],                   "pkg-config": "pcl_common",  "windows": "pcl (vcpkg: pcl)" },
  "OpenNI":          { "includes": ["<NiTE.h>"],                            "pkg-config": "ni",          "windows": "openni (vcpkg: openni)" },

  "TensorFlow C":    { "includes": ["<tensorflow/c/c_api.h>"],               "pkg-config": "tensorflow", "windows": "tensorflow (vcpkg: tensorflow-c)" },
  "LibTorch":        { "includes": ["<torch/torch.h>"],                     "pkg-config": null,          "windows": "libtorch (vcpkg: libtorch-cpu)" },
  "Caffe":           { "includes": ["<caffe/caffe.hpp>"],                    "pkg-config": "caffe",      "windows": "caffe (manual build)" },
  "MXNet":           { "includes": ["<mxnet/c_api.h>"],                     "pkg-config": null,          "windows": "mxnet (manual build)" },
  "XGBoost":         { "includes": ["<xgboost/c_api.h>"],                   "pkg-config": null,          "windows": "xgboost (vcpkg: xgboost)" },
  "LightGBM":        { "includes": ["<LightGBM/c_api.h>"],                 "pkg-config": null,          "windows": "lightgbm (vcpkg: lightgbm)" },
  "ONNX Runtime":    { "includes": ["<onnxruntime_c_api.h>"],              "pkg-config": "onnxruntime", "windows": "onnxruntime (vcpkg: onnxruntime)" },
  "mlpack":          { "includes": ["<mlpack/core.hpp>"],                  "pkg-config": "mlpack",      "windows": "mlpack (vcpkg: mlpack)" },
  "Shark":           { "includes": ["<Shark.h>"],                          "pkg-config": null,          "windows": "shark (manual build)" },
  "Shogun":          { "includes": ["<shogun/lib/config.h>"],               "pkg-config": "shogun",      "windows": "shogun (vcpkg: shogun)" },

  "Qt5":             { "includes": ["<QtWidgets/QApplication>", "<QApplication>"], "pkg-config": null,    "windows": "qt5 (Qt installer)" },
  "Qt6":             { "includes": ["<QtWidgets/QApplication>", "<QApplication>"], "pkg-config": null,    "windows": "qt6 (Qt installer)" },
  "GTK+3":           { "includes": ["<gtk/gtk.h>"],                        "pkg-config": "gtk+-3.0",  "windows": "gtk3 (vcpkg: gtk3)" },
  "GTK+4":           { "includes": ["<gtk/gtk.h>"],                        "pkg-config": "gtk4",      "windows": "gtk4 (vcpkg: gtk4)" },
  "wxWidgets":       { "includes": ["<wx/wx.h>"],                          "pkg-config": "wxwidgets", "windows": "wxwidgets (vcpkg: wxwidgets)" },
  "FLTK":            { "includes": ["<FL/Fl.H>"],                          "pkg-config": "fltk",       "windows": "fltk (vcpkg: fltk)" },
  "ImGui":           { "includes": ["<imgui.h>"],                         "pkg-config": null,          "windows": "ImGui (header-only)" },
  "JUCE":            { "includes": ["<JuceHeader.h>"],                    "pkg-config": null,          "windows": "JUCE (Projucer)" },
  "Clutter":         { "includes": ["<clutter-1.0/clutter/clutter.h>"],       "pkg-config": "clutter-1.0","windows": "clutter (no Win port)" },
  "EFL":             { "includes": ["<Elementary.h>"],                     "pkg-config": "efl",        "windows": "EFL (no Win port)" },
  "OpenVR":          { "includes": ["<openvr.h>"],                         "pkg-config": null,          "windows": "OpenVR (SteamVR SDK)" },

  "PortAudio":       { "includes": ["<portaudio.h>"],                      "pkg-config": "portaudio-2.0", "windows": "portaudio (vcpkg: portaudio)" },
  "OpenAL":          { "includes": ["<AL/al.h>", "<AL/alc.h>"],             "pkg-config": "openal",      "windows": "OpenAL (vcpkg: openal-soft)" },
  "SDL2_mixer":      { "includes": ["<SDL2/SDL_mixer.h>"],               "pkg-config": "SDL2_mixer",  "windows": "SDL2_mixer (vcpkg: sdl2-mixer)" },
  "libsndfile":      { "includes": ["<sndfile.h>"],                      "pkg-config": "sndfile",     "windows": "libsndfile (vcpkg: libsndfile)" },
  "libvorbis":       { "includes": ["<vorbis/vorbisfile.h>"],            "pkg-config": "vorbis",      "windows": "libvorbis (vcpkg: libvorbis)" },
  "libogg":          { "includes": ["<ogg/ogg.h>"],                      "pkg-config": "ogg",         "windows": "libogg (vcpkg: libogg)" },
  "libFLAC":         { "includes": ["<FLAC/stream_decoder.h>"],           "pkg-config": "FLAC",        "windows": "libFLAC (vcpkg: libflac)" },
  "libopus":         { "includes": ["<opus/opus.h>"],                    "pkg-config": "opus",        "windows": "libopus (vcpkg: opus)" },
  "libopusfile":     { "includes": ["<opusfile.h>"],                     "pkg-config": "opusfile",    "windows": "libopusfile (vcpkg: opusfile)" },
  "libmpg123":       { "includes": ["<mpg123.h>"],                      "pkg-config": "mpg123",      "windows": "libmpg123 (vcpkg: mpg123)" },
  "JACK":            { "includes": ["<jack/jack.h>"],                   "pkg-config": "jack",        "windows": "JACK (no Win port)" },
  "FFmpeg":          { "includes": ["<libavcodec/avcodec.h>", "<libavformat/avformat.h>"], "pkg-config": "libavcodec", "windows": "FFmpeg (vcpkg: ffmpeg)" },
  "GStreamer":       { "includes": ["<gst/gst.h>"],                     "pkg-config": "gstreamer-1.0", "windows": "GStreamer (vcpkg: gstreamer)" },

  "libcurl":         { "includes": ["<curl/curl.h>"],                   "pkg-config": "libcurl",     "windows": "curl (vcpkg: curl)" },
  "libssh":          { "includes": ["<libssh/libssh.h>"],               "pkg-config": "libssh",      "windows": "libssh (vcpkg: libssh)" },
  "libssh2":         { "includes": ["<libssh2.h>"],                    "pkg-config": "libssh2",     "windows": "libssh2 (vcpkg: libssh2)" },
  "libuv":           { "includes": ["<uv.h>"],                          "pkg-config": "libuv",       "windows": "libuv (vcpkg: libuv)" },
  "libevent":        { "includes": ["<event2/event.h>"],               "pkg-config": "libevent",    "windows": "libevent (vcpkg: libevent)" },
  "ZeroMQ":          { "includes": ["<zmq.h>"],                         "pkg-config": "libzmq",      "windows": "ZeroMQ (vcpkg: zeromq)" },
  "Poco::Net":       { "includes": ["<Poco/Net/HTTPClientSession.h>"],   "pkg-config": null,          "windows": "Poco::Net (vcpkg: poco)" },
  "Boost.Asio":      { "includes": ["<boost/asio.hpp>"],               "pkg-config": null,          "windows": "Boost.Asio (vcpkg)" },
  "OpenSSL":         { "includes": ["<openssl/ssl.h>"],                "pkg-config": "openssl",     "windows": "OpenSSL (vcpkg: openssl)" },
  "libsodium":       { "includes": ["<sodium.h>"],                     "pkg-config": "libsodium",   "windows": "libsodium (vcpkg: libsodium)" },
  "libgcrypt":       { "includes": ["<gcrypt.h>"],                    "pkg-config": "gcrypt",      "windows": "libgcrypt (vcpkg: libgcrypt)" },

  "GLib":            { "includes": ["<glib.h>"],                       "pkg-config": "glib-2.0",    "windows": "GLib (vcpkg: glib)" },
  "libxml2":         { "includes": ["<libxml/parser.h>"],              "pkg-config": "libxml-2.0",  "windows": "libxml2 (vcpkg: libxml2)" },
  "libxslt":         { "includes": ["<libxslt/xslt.h>"],               "pkg-config": "libxslt",     "windows": "libxslt (vcpkg: libxslt)" },
  "SQLite":          { "includes": ["<sqlite3.h>"],                    "pkg-config": "sqlite3",     "windows": "SQLite3 (vcpkg: sqlite3)" },
  "zlib":            { "includes": ["<zlib.h>"],                       "pkg-config": "zlib",        "windows": "zlib (vcpkg: zlib)" },
  "bzip2":           { "includes": ["<bzlib.h>"],                      "pkg-config": "bz2",         "windows": "bzip2 (vcpkg: bzip2)" },
  "LZ4":             { "includes": ["<lz4.h>"],                        "pkg-config": null,          "windows": "LZ4 (vcpkg: lz4)" },
  "Boost.System":    { "includes": ["<boost/system/error_code.hpp>"],    "pkg-config": null,          "windows": "Boost.System (vcpkg)" },
  "Boost.Filesystem":{"includes": ["<boost/filesystem.hpp>"],           "pkg-config": null,          "windows": "Boost.Filesystem (vcpkg)" },
  "PCRE":            { "includes": ["<pcre.h>"],                       "pkg-config": "libpcre",     "windows": "PCRE (vcpkg: pcre)" },
  "PCRE2":           { "includes": ["<pcre2.h>"],                      "pkg-config": "libpcre2-8",  "windows": "PCRE2 (vcpkg: pcre2)" },
  "libgd":          { "includes": ["<gd.h>"],                         "pkg-config": "gd",          "windows": "GD (vcpkg: gd)" },
  "FreeType":        { "includes": ["<ft2build.h>"],                    "pkg-config": "freetype2",   "windows": "FreeType (vcpkg: freetype)" },
  "JPEG":            { "includes": ["<jpeglib.h>"],                    "pkg-config": "libjpeg",     "windows": "libjpeg-turbo (vcpkg: libjpeg-turbo)" },
  "PNG":             { "includes": ["<png.h>"],                        "pkg-config": "libpng",      "windows": "libpng (vcpkg: libpng)" },
  "TIFF":            { "includes": ["<tiffio.h>"],                     "pkg-config": "libtiff-4",   "windows": "libtiff (vcpkg: libtiff)" },
  "WebP":            { "includes": ["<webp/decode.h>"],                "pkg-config": "libwebp",     "windows": "libwebp (vcpkg: libwebp)" },
  "OpenCL":          { "includes": ["<CL/cl.h>"],                      "pkg-config": "OpenCL",      "windows": "OpenCL (drivers)" },
  "Vulkan":          { "includes": ["<vulkan/vulkan.h>"],              "pkg-config": "vulkan",      "windows": "Vulkan (vcpkg: vulkan-loader)" },
  "libffi":          { "includes": ["<ffi.h>"],                        "pkg-config": "libffi",      "windows": "libffi (vcpkg: libffi)" },
  "UUID":            { "includes": ["<uuid/uuid.h>"],                 "pkg-config": "libuuid",     "windows": "RPC (Win API)" },
  "MPI":             { "includes": ["<mpi.h>"],                        "pkg-config": "mpi",         "windows": "MS MPI (vcpkg: msmpi)" },
  "OpenMP":          { "includes": ["<omp.h>"],                        "pkg-config": null,          "windows": "MS OpenMP (compiler)" },
  "OpenACC":         { "includes": ["<openacc.h>"],                    "pkg-config": null,          "windows": "OpenACC (PGI)" },
  "OpenSSL.Crypto":  { "includes": ["<openssl/crypto.h>"],             "pkg-config": "openssl",     "windows": "OpenSSL (vcpkg: openssl)" },
  "BoringSSL":       { "includes": ["<openssl/ssl.h>"],                "pkg-config": null,          "windows": "BoringSSL (build)" },
  "mbedTLS":         { "includes": ["<mbedtls/md5.h>"],                "pkg-config": "mbedtls",     "windows": "mbedTLS (vcpkg)" },
  "WolfSSL":         { "includes": ["<wolfssl/options.h>"],            "pkg-config": null,          "windows": "WolfSSL (vcpkg)" },

  "PostgreSQL":      { "includes": ["<libpq-fe.h>"],                   "pkg-config": "libpq",       "windows": "PostgreSQL (vcpkg)" },
  "MySQL":           { "includes": ["<mysql.h>"],                      "pkg-config": null,          "windows": "MySQL (Connector/C)" },
  "LevelDB":         { "includes": ["<leveldb/db.h>"],                "pkg-config": "leveldb",     "windows": "LevelDB (vcpkg)" },
  "LMDB":            { "includes": ["<lmdb.h>"],                       "pkg-config": null,          "windows": "LMDB (vcpkg)" },
  "HDF5":            { "includes": ["<hdf5.h>"],                      "pkg-config": "hdf5",        "windows": "HDF5 (vcpkg)" },
  "NetCDF":          { "includes": ["<netcdf.h>"],                    "pkg-config": "netcdf",      "windows": "NetCDF (vcpkg)" },
  "YAML-CPP":        { "includes": ["<yaml-cpp/yaml.h>"],             "pkg-config": null,          "windows": "yaml-cpp (vcpkg)" },
  "nlohmann_json":   { "includes": ["<nlohmann/json.hpp>"],            "pkg-config": null,          "windows": "nlohmann-json (vcpkg)" },
  "RapidJSON":       { "includes": ["<rapidjson/document.h>"],         "pkg-config": null,          "windows": "RapidJSON (header)" },
  "FlatBuffers":     { "includes": ["<flatbuffers/flatbuffers.h>"],     "pkg-config": null,          "windows": "FlatBuffers (vcpkg)" },
  "CapnProto":       { "includes": ["<capnp/message.h>"],             "pkg-config": "capnp",       "windows": "Cap’n Proto (vcpkg)" },
  "Bullet":          { "includes": ["<btBulletDynamicsCommon.h>"],      "pkg-config": "bullet",      "windows": "Bullet (vcpkg: bullet3)" },
  "ODE":             { "includes": ["<ode/ode.h>"],                    "pkg-config": "ode",         "windows": "ODE (manual)" },
  "Magnum":          { "includes": ["<Magnum/Magnum.h>"],              "pkg-config": "magnum",      "windows": "Magnum (vcpkg)" },

  // Additional / header-only libraries:
  "Eigen3":         { "includes": ["<Eigen/Dense>"],                 "pkg-config": null,         "windows": "Eigen (header-only)" },
  "GLM":            { "includes": ["<glm/glm.hpp>"],                 "pkg-config": "glm",        "windows": "GLM (vcpkg)" },
  "Armadillo":      { "includes": ["<armadillo>"],                  "pkg-config": "armadillo",  "windows": "Armadillo (vcpkg)" },
  "OpenEXR":        { "includes": ["<OpenEXR/ImfRgbaFile.h>"],       "pkg-config": "OpenEXR",    "windows": "OpenEXR (vcpkg)" },
  "Boost.Graph":    { "includes": ["<boost/graph/adj_list.hpp>"],     "pkg-config": null,         "windows": "Boost.Graph (vcpkg)" },
  "Boost.Regex":    { "includes": ["<boost/regex.hpp>"],             "pkg-config": null,         "windows": "Boost.Regex (vcpkg)" },
  "Boost.Coroutine":{ "includes": ["<boost/coroutine2/all.hpp>"],    "pkg-config": null,         "windows": "Boost.Coroutine (vcpkg)" },
  "Boost.System ":   { "includes": ["<boost/system/error_code.hpp>"], "pkg-config": null,         "windows": "Boost.System (vcpkg)" },
  "Boost.Filesystem ": {"includes": ["<boost/filesystem.hpp>"],       "pkg-config": null,         "windows": "Boost.Filesystem (vcpkg)" },

  // Miscellaneous popular libraries:
  "OpenCL ":        { "includes": ["<CL/cl.h>"],                   "pkg-config": "OpenCL",      "windows": "OpenCL (drivers)" },
  "Vulkan ":        { "includes": ["<vulkan/vulkan.h>"],           "pkg-config": "vulkan",      "windows": "Vulkan (vcpkg)" },
  "OpenXR":        { "includes": ["<openxr/openxr.h>"],          "pkg-config": "openxr",      "windows": "OpenXR (SDK)" },
  "SDL2_image":    { "includes": ["<SDL2/SDL_image.h>"],         "pkg-config": "SDL2_image",  "windows": "SDL2_image (vcpkg)" },
  "SDL2_ttf":      { "includes": ["<SDL2/SDL_ttf.h>"],           "pkg-config": "SDL2_ttf",    "windows": "SDL2_ttf (vcpkg)" },
  "libtheora":     { "includes": ["<theora/theoradec.h>"],       "pkg-config": "theora",      "windows": "libtheora (vcpkg)" },
  "libspeex":      { "includes": ["<speex/speex.h>"],           "pkg-config": "speex",       "windows": "libspeex (vcpkg)" },
  "SDL2_gfx":      { "includes": ["<SDL2/SDL2_gfxPrimitives.h>"],"pkg-config": "SDL2_gfx",    "windows": "SDL2_gfx (vcpkg)" },
  "Magick++":      { "includes": ["<Magick++.h>"],              "pkg-config": "Magick++-7.Q16HDRI", "windows": "ImageMagick (Magick++)" },
  "gtest":         { "includes": ["<gtest/gtest.h>"],           "pkg-config": null,          "windows": "gtest (vcpkg)" },
  "nanomsg":       { "includes": ["<nanomsg/nn.h>"],            "pkg-config": "nanomsg",     "windows": "nanomsg (vcpkg)" },
  "MongoDB C++":   { "includes": ["<mongocxx/client.hpp>"],      "pkg-config": "mongo-cxx-driver", "windows": "mongo-cxx-driver (vcpkg)" },
  "cJSON":         { "includes": ["<cjson/cJSON.h>"],           "pkg-config": "libcjson",    "windows": "cJSON (vcpkg)" },
  "libstrophe":    { "includes": ["<strophe.h>"],               "pkg-config": "libstrophe",  "windows": "libstrophe (vcpkg)" },
  "Lua":           { "includes": ["<lua.hpp>"],                 "pkg-config": "lua5.3",      "windows": "Lua (vcpkg)" },
  "PugiXML":       { "includes": ["<pugixml.hpp>"],             "pkg-config": null,          "windows": "PugiXML (header)" },
  "TinyXML":       { "includes": ["<tinyxml.h>"],              "pkg-config": "tinyxml",     "windows": "TinyXML (vcpkg)" },
  "tinydir":       { "includes": ["<tinydir.h>"],              "pkg-config": null,          "windows": "tinydir (header)" },
  "Magnum Math":   { "includes": ["<Magnum/Math/Vector3.h>"],   "pkg-config": "magnum-math","windows": "Magnum (vcpkg)" },
  "HDF4":          { "includes": ["<mfhdf.h>"],               "pkg-config": "hdf4",        "windows": "HDF4 (vcpkg)" },
  "OpenXR ":        { "includes": ["<openxr/openxr.h>"],         "pkg-config": "openxr",      "windows": "OpenXR (SDK)" },
  "SOIL":          { "includes": ["<SOIL.h>"],                "pkg-config": null,          "windows": "SOIL (library)" }
};

// Dart function to detect pkg-config packages from source includes
List<String> detectPkgConfig(String source) {
  final List<String> pkgs = [];
  libraries.forEach((name, info) {
    final List<dynamic> incs = info["includes"];
    final pkgName = info["pkg-config"];
    if (pkgName == null) return;
    for (var inc in incs) {
      if (source.contains(inc)) {
        if (!pkgs.contains(pkgName)) {
          pkgs.add(pkgName);
        }
        break;
      }
    }
  });
  return pkgs;
}
