from pathlib import Path

import json
import cbor2

EXTRA = 'data/extra.json'
SOURCE = 'data/kanjiapi_full.json'
TARGET = 'data/kanjiapi_full.cbor'

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
        print(f'{SOURCE} not exists')
        return

    with open(SOURCE) as file:
        content: KanjiDict = json.load(file)['kanjis']

    filtered: KanjiDict = {}
    for kanji, value in content.items():
        filtered[kanji] = map_kanji(value)

    with open(EXTRA) as file:
        content = json.load(file)

    for kanji, value in content.items():
        if kanji in filtered:
            print(f'{EXTRA} contains kanji {kanji} which is already defined, skipping')
            continue
        filtered[kanji] = map_kanji(value)

    with open(TARGET, 'wb') as file:
        cbor2.dump(filtered, file)
    # json size is about x2 of cbor
    # with open('data/kanjiapi_full.json', 'w') as file:
    #     json.dump(filtered, file)


if __name__ == '__main__':
    main()
