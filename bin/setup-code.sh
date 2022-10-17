#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202210162208-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.com
# @@License          :  WTFPL
# @@ReadME           :  setup-code.sh --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Sunday, Oct 16, 2022 22:08 EDT
# @@File             :  setup-code.sh
# @@Description      :
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/start-service
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
code --install-extension "aaron-bond.better-comments" --force
code --install-extension "bengreenier.vscode-node-readme" --force
code --install-extension "bierner.emojisense" --force
code --install-extension "bierner.github-markdown-preview" --force
code --install-extension "bierner.markdown-checkbox" --force
code --install-extension "bierner.markdown-emoji" --force
code --install-extension "bierner.markdown-footnotes" --force
code --install-extension "bierner.markdown-mermaid" --force
code --install-extension "bierner.markdown-preview-github-styles" --force
code --install-extension "bierner.markdown-yaml-preamble" --force
code --install-extension "bmalehorn.vscode-fish" --force
code --install-extension "bungcip.better-toml" --force
code --install-extension "christian-kohler.npm-intellisense" --force
code --install-extension "Cjay.ruby-and-rails-snippets" --force
code --install-extension "compilouit.manpage" --force
code --install-extension "coolbear.systemd-unit-file" --force
code --install-extension "d9705996.perl-toolbox" --force
code --install-extension "DavidAnson.vscode-markdownlint" --force
code --install-extension "dbaeumer.vscode-eslint" --force
code --install-extension "denoland.vscode-deno" --force
code --install-extension "dnicolson.binary-plist" --force
code --install-extension "dotiful.dotfiles-syntax-highlighting" --force
code --install-extension "DotJoshJohnson.xml" --force
code --install-extension "dsznajder.es7-react-js-snippets" --force
code --install-extension "duniul.dircolors" --force
code --install-extension "dunstontc.viml" --force
code --install-extension "EditorConfig.EditorConfig" --force
code --install-extension "eiminsasete.apacheconf-snippets" --force
code --install-extension "esbenp.prettier-vscode" --force
code --install-extension "file-icons.file-icons" --force
code --install-extension "formulahendry.auto-rename-tag" --force
code --install-extension "foxundermoon.shell-format" --force
code --install-extension "ginfuru.ginfuru-vscode-jekyll-syntax" --force
code --install-extension "ginfuru.vscode-jekyll-snippets" --force
code --install-extension "glenn2223.live-sass" --force
code --install-extension "hangxingliu.vscode-nginx-conf-hint" --force
code --install-extension "HexcodeTechnologies.vscode-prettydiff" --force
code --install-extension "hogashi.crontab-syntax-highlight" --force
code --install-extension "justusadam.language-haskell" --force
code --install-extension "keyring.Lua" --force
code --install-extension "malmaud.tmux" --force
code --install-extension "MariusAlchimavicius.json-to-ts" --force
code --install-extension "mechatroner.rainbow-csv" --force
code --install-extension "mrmlnc.vscode-apache" --force
code --install-extension "ms-azuretools.vscode-docker" --force
code --install-extension "ms-vscode-remote.remote-containers" --force
code --install-extension "ms-vscode.powershell" --force
code --install-extension "ms-vscode.vscode-typescript-tslint-plugin" --force
code --install-extension "nico-castell.linux-desktop-file" --force
code --install-extension "octref.vetur" --force
code --install-extension "oderwat.indent-rainbow" --force
code --install-extension "piotrpalarz.vscode-gitignore-generator" --force
code --install-extension "quicktype.quicktype" --force
code --install-extension "rebornix.ruby" --force
code --install-extension "redhat.vscode-yaml" --force
code --install-extension "ritwickdey.LiveServer" --force
code --install-extension "rohgarg.jekyll-post" --force
code --install-extension "rpinski.shebang-snippets" --force
code --install-extension "sastan.twind-intellisense" --force
code --install-extension "Shan.code-settings-sync" --force
code --install-extension "sidneys1.gitconfig" --force
code --install-extension "sissel.shopify-liquid" --force
code --install-extension "streetsidesoftware.code-spell-checker" --force
code --install-extension "swyphcosmo.spellchecker" --force
code --install-extension "syler.sass-indented" --force
code --install-extension "tanming363.bootstrap-v4" --force
code --install-extension "timonwong.shellcheck" --force
code --install-extension "TzachOvadia.todo-list" --force
code --install-extension "VisualStudioExptTeam.intellicode-api-usage-examples" --force
code --install-extension "VisualStudioExptTeam.vscodeintellicode" --force
code --install-extension "vscode-icons-team.vscode-icons" --force
code --install-extension "vscode-snippet.snippet" --force
code --install-extension "WakaTime.vscode-wakatime" --force
code --install-extension "wingrunr21.vscode-ruby" --force
code --install-extension "Wscats.eno" --force
code --install-extension "yinfei.luahelper" --force
code --install-extension "yzhang.markdown-all-in-one" --force
code --install-extension "ZainChen.json" --force
curl -q -LSsf "https://github.com/casjay/vs-code/raw/main/settings-linux.json" -o "$HOME/.config/Code/User/settings.json"

