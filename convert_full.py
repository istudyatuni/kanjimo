from pathlib import Path

import json
import cbor2

EXTRA = 'data/extra.json'
SOURCE = 'data/kanjiapi_full.json'
TARGET = 'data/kanjiapi_full.cbor'


def main():
    if not Path(SOURCE).exists():
        print(f'{SOURCE} not exists')
        return

    with open(SOURCE) as file:
        content = json.load(file)

    filtered = {}
    for kanji, value in content['kanjis'].items():
        filtered[kanji] = {
            'on': value['on_readings'],
            'kun': value['kun_readings'],
            'meanings': value['meanings'],
        }

    with open(EXTRA) as file:
        content = json.load(file)

    for kanji, value in content.items():
        filtered[kanji] = {
            'on': value['on'],
            'kun': value['kun'],
            'meanings': value['meanings'],
        }

    with open('data/kanjiapi_full.cbor', 'wb') as file:
        cbor2.dump(filtered, file)
    # json size is about x2 of cbor
    # with open('data/kanjiapi_full.json', 'w') as file:
    #     json.dump(filtered, file)


if __name__ == '__main__':
    main()
