{ stdenv
, mkDerivation
, fetchurl
, autoPatchelfHook
, pkg-config
, ffmpeg_3
, openssl
, qtbase
, zlib

, withJava ? true
, jre_headless
}:

let
  version = "1.15.4";
  # Using two URLs as the first one will break as soon as a new version is released
  src_bin = fetchurl {
    urls = [
      "http://www.makemkv.com/download/makemkv-bin-${version}.tar.gz"
      "http://www.makemkv.com/download/old/makemkv-bin-${version}.tar.gz"
    ];
    hash = "sha256-Reun5hp7Rnsf6N5yL6iQ1Vbhnz/AKnt/jYRqyOK625o=";
  };
  src_oss = fetchurl {
    urls = [
      "http://www.makemkv.com/download/makemkv-oss-${version}.tar.gz"
      "http://www.makemkv.com/download/old/makemkv-oss-${version}.tar.gz"
    ];
    hash = "sha256-gtBi1IRNF5ASk/ZdzkDmOuEIT9gazNaRNCftqbLEP+M=";
  };
in mkDerivation {
  pname = "makemkv";
  inherit version;

  srcs = [ src_bin src_oss ];

  sourceRoot = "makemkv-oss-${version}";

  nativeBuildInputs = [ autoPatchelfHook pkg-config ];

  buildInputs = [ ffmpeg_3 openssl qtbase zlib ];

  qtWrapperArgs =
    let
      binPath = stdenv.lib.makeBinPath [ jre_headless ];
    in stdenv.lib.optionals withJava [
      ''--prefix PATH : ${binPath}''
    ];

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin           out/makemkv ../makemkv-bin-${version}/bin/amd64/makemkvcon
    install -D     -t $out/lib           out/lib{driveio,makemkv,mmbd}.so.*
    install -D     -t $out/share/MakeMKV ../makemkv-bin-${version}/src/share/*

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Convert blu-ray and dvd to mkv";
    longDescription = ''
      makemkv is a one-click QT application that transcodes an encrypted
      blu-ray or DVD disc into a more portable set of mkv files, preserving
      subtitles, chapter marks, all video and audio tracks.

      Program is time-limited -- it will stop functioning after 60 days. You
      can always download the latest version from makemkv.com that will reset the
      expiration date.
    '';
    license = licenses.unfree;
    homepage = "http://makemkv.com";
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ danieldk titanous ];
  };
}
