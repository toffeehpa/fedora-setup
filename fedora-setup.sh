# возможно понадобится systemd-run --user --scope fedora-setup.sh, чтобы при killall -SIGQUIT gnome-shell скрипт продолжал работу

# Обновление, установка и загрузка всего необходимого
sudo dnf update -y && sudo dnf install -y gnome-todo gnome-tweaks gnome-extensions gnome-shell-extension-dash-to-dock gnome-shell-extension-places-menu gnome-shell-extension-gsconnect evolution gvfs-google ibm-plex-fonts-all && sudo dnf remove -y google-noto-color-emoji-fonts google-noto-emoji-fonts 
sudo dnf remove "libreoffice*"
#sudo dnf remove gnome-software # рецидив, раз уж существует решение как flathub.org, то такой бестолковый магазин не нужен. Но его удаление всё таки будет опциональным
#И зачем нужен libreoffice с коробки когда оригинальный Microsoft Office давно существует в web?
sudo dnf install -y twitter-twemoji-fonts #было вынесено отдельно ибо эти эмодзи будут тестироваться
sudo git clone https://github.com/toffeehpa/kora-modified.git /usr/share/icons/kora

# Процессинг и настройка

gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
gsettings set org.gnome.desktop.interface antialiasing 'rgba' #<140 = rgba, >140 = grayscale + none hinting
#gsettings set org.gnome.desktop.interface hinting 'none'
gsettings set org.gnome.desktop.interface icon-theme 'kora'
gsettings set org.gnome.desktop.interface font-name 'IBM Plex Sans 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'IBM Plex Sans Bold 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'IBM Plex Mono 12'
gsettings set org.gnome.desktop.interface document-font-name 'IBM Plex Serif 11'
gsettings set org.gnome.TextEditor use-system-font false
gsettings set org.gnome.TextEditor custom-font 'IBM Plex Sans 12'
# Какой деградант умудрился monospace шрифт в текстовый редактор запихнуть, это не терминал и не IDE? Что у них в бошках? А в итоге исправлять мне. Кто-то там явно на приколе в разработке сидит

#killall -SIGQUIT gnome-shell
#busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable places-menu@gnome-shell-extensions.gcampax.github.com

#- - - - - - - - - - - - Not GNOME - - - - - - - - - - - -
sudo systemctl enable --now systemd-oomd
sudo systemctl enable --now systemd-tmpfiles-clean.timer
sudo systemctl enable --now fstrim.timer
sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable --now fwupd-refresh.timer
#sudo systemctl enable --now thermald # intel-only
sudo systemctl enable --now irqbalance

sudo tee /etc/sysctl.d/99-memory-tuning.conf >/dev/null <<'EOF'
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF

sudo tee /etc/systemd/zram-generator.conf >/dev/null <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = lz4
swap-priority = 100
EOF

sudo tee /etc/dnf/dnf.conf >/dev/null <<'EOF'
[main]
clean_requirements_on_remove=True
best=True
fastestmirror=True
defaultyes=True
keepcache=True	
EOF
