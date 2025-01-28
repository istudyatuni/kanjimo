[private]
@default:
	just --list

install path="$HOME/.local/share/typst/packages/local" pkg="kanji-practice/0.1.0":
	mkdir -p "{{ path }}/{{ pkg }}/data"
	cp {src,lib}.typ "{{ path }}/{{ pkg }}"
	cp typst.toml "{{ path }}/{{ pkg }}"
	cp data/kanjiapi_full.cbor "{{ path }}/{{ pkg }}/data"

install-fonts path="$HOME/.local/share/fonts":
	mkdir -p "{{ path }}"
	cp fonts/* "{{ path }}"

bundle:
    rm -rf bundle
    mkdir -p bundle bundle/docs bundle/data
    cp docs/typst-screenshot.png bundle/docs
    cp data/kanjiapi_full.cbor bundle/data
    cp lib.typ src.typ typst.toml bundle

    # simple test
    echo '#import "bundle/lib.typ": practice' | typst c - /dev/null -f pdf
