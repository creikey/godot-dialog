#!/usr/bin/env bash

if [ "$USER" == "creikey" ]; then
if [ ! -f "tmp.tres" ]; then # avoid overriding previously cached tmp ( after failed script )
	cp /home/creikey/.config/godot/editor_settings-3.tres tmp.tres
fi
fi

rm -r exports
mkdir -p exports/linux
mkdir -p exports/windows
mkdir -p exports/mac
godot-headless --path editor --export windows "$(readlink -f ./exports/windows/godot-dialog.exe)"
godot-headless --path editor --export linux "$(readlink -f ./exports/linux/godot-dialog.x86_64)"
godot-headless --path editor --export mac "$(readlink -f ./exports/mac/Godot\ Dialog)"
if [ "$?" == "0" ]; then
	butler -i ~/.config/itch/creikey push exports/windows creikey/godot-dialog:windows
	butler -i ~/.config/itch/creikey push exports/linux creikey/godot-dialog:linux

	cd exports/mac
	mv Godot\ Dialog "Godot\ Dialog.zip"
	unzip "Godot\ Dialog.zip"
	butler -i ~/.config/itch/creikey push Godot\ Dialog.app creikey/godot-dialog:mac 
	cd -
fi

if [ "$USER" == "creikey" ]; then
	mv tmp.tres /home/creikey/.config/godot/editor_settings-3.tres
fi
