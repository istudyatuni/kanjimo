[private]
@default:
    just --list

install path="$HOME/.local/share/typst/packages/local" pkg="kanji-practice/0.1.0": bundle
    rm -rf "{{ path }}/{{ pkg }}"
    mv bundle "{{ path }}/{{ pkg }}"

install-fonts path="$HOME/.local/share/fonts":
    mkdir -p "{{ path }}"
    cp fonts/* "{{ path }}"

bundle:
    rm -rf bundle
    mkdir -p bundle bundle/docs bundle/data
    cp docs/typst-screenshot.png bundle/docs
    cp data/kanjiapi_full.cbor bundle/data
    cp lib.typ src.typ typst.toml bundle

    @# simple test
    echo '#import "bundle/lib.typ": practice; #practice("私")' | typst c - /dev/null -f pdf
