from pathlib import Path

import cbor2
import hashlib
import json
import zipfile

DIR = Path('data')
BASE_FILE = 'kanjiapi_full'

CBOR_FILE = BASE_FILE + '.cbor'
JSON_FILE = BASE_FILE + '.json'

SOURCE = DIR.joinpath(JSON_FILE)
SOURCE_ZIP = DIR.joinpath(f'{BASE_FILE}.zip')
EXTRA = DIR.joinpath('extra.json')
TARGET = DIR.joinpath(CBOR_FILE)

LOCK = DIR.joinpath('data.lock.json')

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


def check_files() -> bool:
    if not Path(SOURCE).exists():
        print(f'{SOURCE} not exists, searching .zip file')
        if not Path(SOURCE_ZIP).exists():
            print(f'{SOURCE_ZIP} not exists')
            return True

        print(f'extracting {SOURCE_ZIP}')
        with zipfile.ZipFile(SOURCE_ZIP) as file:
            file.extract(JSON_FILE, path=DIR)

    return False


def save_cbor(data: bytes):
    with open(TARGET, mode='wb') as file:
        file.write(data)


def check_cbor(data: bytes):
    key = CBOR_FILE

    if not Path(LOCK).exists():
        with open(LOCK, mode='w') as file:
            file.write('{}')

    hasher = hashlib.sha256(data)
    new_hash = hasher.hexdigest()

    with open(LOCK) as file:
        content = json.load(file)

    if key in content and content[key] != '':
        orig_hash = content[key]
        if orig_hash != new_hash:
            print(f'hash of {TARGET} changed. to update, remove hash from {LOCK}')
            print(f'old {orig_hash}')
            print(f'new {new_hash}')
            return

        if not TARGET.exists():
            save_cbor(data)
        else:
            print(f'{TARGET} not changed')

        return

    save_cbor(data)
    with open(LOCK, mode='w') as file:
        json.dump({key: new_hash}, file)


def main():
    if check_files():
        return

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

    encoded: bytes = cbor2.dumps(filtered)
    check_cbor(encoded)
    # json size is about x2 of cbor
    # with open('data/kanjiapi_full-converted.json', 'w') as file:
    #     json.dump(filtered, file)


if __name__ == '__main__':
    main()
