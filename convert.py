from pathlib import Path

import json
import cbor2
import zipfile

EXTRA = 'data/extra.json'
DIR = 'data'
BASE_FILE = 'kanjiapi_full'
JSON_FILE = BASE_FILE + '.json'
SOURCE = Path(DIR).joinpath(JSON_FILE)
SOURCE_ZIP = Path(DIR).joinpath(f'{BASE_FILE}.zip')
TARGET = Path(DIR).joinpath(f'{BASE_FILE}.cbor')

type Kanji = dict[str, list[str]]
type KanjiDict = dict[str, Kanji]


def map_kanji(kanji: Kanji) -> Kanji:
    """
    Map kanji dict

    - `on_readings` to `o`
    - `kun_readings` to `k`
    - `meanings` to `m`

    Short keys are used to reduce output size. Other keys are ignored
    """

    on = kanji.get('on_readings', [])
    kun = kanji.get('kun_readings', [])
    meanings = kanji.get('meanings', [])

    res: Kanji = {}
    if len(on) != 0:
        res['o'] = on
    if len(kun) != 0:
        res['k'] = kun
    if len(meanings) != 0:
        res['m'] = meanings

    return res


def main():
    if not Path(SOURCE).exists():
        print(f'{SOURCE} not exists, searching .zip file')
        if not Path(SOURCE_ZIP).exists():
            print(f'{SOURCE_ZIP} not exists')
            return

        print(f'extracting {SOURCE_ZIP}')
        with zipfile.ZipFile(SOURCE_ZIP) as file:
            file.extract(JSON_FILE, path=DIR)

    with open(SOURCE) as file:
        content: KanjiDict = json.load(file)['kanjis']

    filtered: KanjiDict = {}
    for kanji, value in content.items():
        filtered[kanji] = map_kanji(value)

    with open(EXTRA) as file:
        content = json.load(file)

    total = len(filtered)

    for kanji, value in content.items():
        if kanji in filtered:
            print(f'{EXTRA} contains kanji {kanji} which is already defined, skipping')
            continue
        filtered[kanji] = map_kanji(value)

    extra = len(filtered) - total
    print(f'processed {total} kanji from kanjiapi and {extra} extra kanji')

    with open(TARGET, 'wb') as file:
        cbor2.dump(filtered, file)
    # json size is about x2 of cbor
    # with open('data/kanjiapi_full-converted.json', 'w') as file:
    #     json.dump(filtered, file)


if __name__ == '__main__':
    main()
