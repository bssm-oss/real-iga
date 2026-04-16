cask "real-iga" do
  version :latest
  sha256 :no_check

  url "https://github.com/bssm-oss/real-iga/releases/latest/download/real-iga.zip"
  name "real-iga"
  desc "ㄹ 또는 f 입력 시 ㄹㅇ이가로 자동 치환하는 macOS 메뉴 막대 앱"
  homepage "https://github.com/bssm-oss/real-iga"

  app "real-iga.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{appdir}/real-iga.app"]
  end
end
