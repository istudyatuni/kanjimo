# Convert kanji.json: group kanjis by categories and add categories names

import json


def main():
    with open('data/kanji.json') as f:
        kanji = json.load(f)
    converted = {}
    for i in range(5, 0, -1):
        converted[f'jlptn{i}'] = []
    for k in kanji['kanji']:
        category = k['category']
        del k['category']
        converted[category].append(k)
    kanji = {
        'kanji': {
            'categories': converted,
        },
        'categories': {
            'jlptn1': 'JLPT N1',
            'jlptn2': 'JLPT N2',
            'jlptn3': 'JLPT N3',
            'jlptn4': 'JLPT N4',
            'jlptn5': 'JLPT N5',
        },
    }
    with open('data/kanji2.json', 'w') as f:
        json.dump(kanji, f, indent=4, ensure_ascii=False)


if __name__ == '__main__':
    main()
