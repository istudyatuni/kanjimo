[private]
@default:
	just --list

install path="$HOME/.local/share/typst/packages/local" pkg="kanji-practice/0.1.0":
	mkdir -p "{{ path }}/{{ pkg }}/data"
	cp {src,lib}.typ "{{ path }}/{{ pkg }}"
	cp typst.toml "{{ path }}/{{ pkg }}"
	cp data/kanji{,2}.json "{{ path }}/{{ pkg }}/data"
