#let tr = (
    meaning: "Meaning",
)

#let data = json("data/kanji.json")
#let data2 = json("data/kanji2.json")
#let kanjis = data.kanji
#let kanjis-categorised = data2.kanji
#let categories = array.range(5, 0, step: -1).map(i => "jlptn" + str(i))
#let categories-names = data2.categories

#let show-order(k) = {
    text(font: "KanjiStrokeOrders", fallback: false, size: 5em)[#k]
}

#let show-draw(k) = {
    text(font: "YOzFontN-StdN-R", fallback: false, size: 5em)[#k]
}

#let table-with-meanings(kanji) = {
    table(
        columns: 4,
        stroke: 0.5pt + gray,
        ..kanji.map(k => [#k.character\ #k.meaning])
    )
}

#let jlpt-table(category: none, meanings: false) = {
    set text(font: "mitimasu")

    let map = (:)
    if category != none {
        if categories.find(c => c == category) == none {
            panic("invalid category", category)
        }
        map.insert(category, kanjis-categorised.categories.at(category))
    } else {
        map = kanjis-categorised.categories
    }
    for (name, c) in map {
        [== #categories-names.at(name)]
        if meanings {
            table-with-meanings(c)
        } else {
            for kan in c {
                kan.character
            }
        }
    }
}

#let practice(kanji: "") = {
    let kanjis-list = kanji.clusters()
    if kanjis-list.len() == 0 {
        return
    }
    let kanjis-list = kanjis.fold((), (acc, k) => {
        if kanjis-list.contains(k.character) {
            acc.push(k)
        }
        acc
    })
    let one(body) = box(width: 5em, height: 5em, inset: (y: 5pt))[#body]
    let two(body) = box(width: 5em, height: 5em)[#body]
    for k in kanjis-list {
        let order = two[
            #show-order(k.character)
        ]
        let draw = one[
            #set text(fill: gray)
            #show-draw(k.character)
        ]
        box[
            #strong(tr.meaning): #k.meaning\
            #if k.kunyomi != "" {
                [#strong[Kun]: #k.kunyomi\ ]
            }
            #if k.onyomi != "" {
                [#strong[On]: #k.onyomi]
            }
            #grid(
                columns: 2,
                table(columns: 1, order, one[]),
                table(columns: 6, draw, draw, ..array.range(10).map(_ => one[])),
            )
        ]
    }
}
