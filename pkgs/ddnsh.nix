{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  jq,
  curl,
}:
stdenvNoCC.mkDerivation {
  pname = "ddnsh";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "namescode";
    repo = "ddnsh";
    rev = "main";
    sha256 = "sha256-FivpKqvfgYC9Bwzx9Sei6lI8UlTqEYRy1f0Wf5VGjkk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/ddnsh.sh $out/bin/ddnsh
    chmod +x $out/bin/ddnsh

    wrapProgram $out/bin/ddnsh --prefix PATH : ${
      lib.makeBinPath [
        jq
        curl
      ]
    }
  '';

  meta = with lib; {
    mainProgram = "ddnsh";
    description = "A minimal POSIX shell script to update your dynamic IP in DNS records.";
    homepage = "https://github.com/NamesCode/ddnsh";
    license = licenses.mpl20;
    maintainers = [ maintainers.Name ];
    platforms = platforms.unix;
  };
}
