[private]
@default:
    just --list

install path="$HOME/.local/share/typst/packages/local" pkg="kanji-practice/0.1.0": test bundle
    rm -rf "{{ path }}/{{ pkg }}"
    mv bundle "{{ path }}/{{ pkg }}"

install-fonts path="$HOME/.local/share/fonts":
    mkdir -p "{{ path }}"
    cp fonts/* "{{ path }}"

test:
    tt run

bundle:
    rm -rf bundle
    mkdir -p bundle bundle/docs bundle/data
    cp docs/typst-screenshot.png bundle/docs
    cp data/kanjiapi_full.cbor bundle/data
    cp lib.typ src.typ typst.toml LICENSE bundle
