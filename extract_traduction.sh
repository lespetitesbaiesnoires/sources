#!/bin/bash


echo "### Fichiers globaux"
for file in _data/*; do
	echo "# Fichier : $file"
	cat $file
done

echo "### Pages du site"
for lang in  $(sed -n '/lang:/s/.*:[[:space:]]*\([^[:space:]]*\).*/\1/p' _data/lang.yml); do
	echo "# Langue : $lang"
	for page in $lang/*; do
		echo "# Page : $page"
		cat $page
	done
done
