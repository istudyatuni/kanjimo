[private]
@default:
    just --list

install path="$HOME/.local/share/typst/packages/local" pkg="kanjimo/0.1.0": test bundle
    rm -rf "{{ join(path, pkg) }}"
    mkdir -p "{{ parent_directory(join(path, pkg)) }}"
    mv bundle "{{ join(path, pkg) }}"

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
    cp lib.typ src.typ typst.toml LICENSE README.md bundle

publish repo version: (install join(repo, "packages/preview") "kanjimo/" + version)

convert-kanji:
    python3 convert.py

format:
    ruff format
