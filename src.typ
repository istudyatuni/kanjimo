#let data = json("data/kanji.json")
#let data2 = json("data/kanji2.json")
#let kanjis = data.kanji
#let kanjis-categorised = data2.kanji
#let categories-dict = {
    data2.categories
        .keys()
        .fold((:), (acc, c) => {
            acc.insert(c, c)
            acc
        })
}
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
        if categories-dict.at(category, default: none) == none {
            panic("invalid category", category)
        }
        map.insert(category, kanjis-categorised.categories.at(category))
    } else {
        map = kanjis-categorised.categories
    }
    for (name, c) in map {
        [= #categories-names.at(name)]
        if meanings {
            table-with-meanings(c)
        } else {
            for kan in c {
                kan.character
            }
        }
    }
}

#let practice-kanji(kanji) = {
    set box(width: 5em, height: 5em)

    let empty = box(inset: (y: 5pt))
    let order = box[#show-order(kanji.character)]
    let draw = box(inset: (y: 5pt))[
        #set text(fill: gray)
        #show-draw(kanji.character)
    ]
    let opt(name, value) = if value.len() > 0 { [#strong[#name]: #value] }
    box(width: auto, height: auto)[
        #strong("Meaning"): #kanji.meaning \
        #opt("Kun", kanji.kunyomi) \
        #opt("On", kanji.onyomi)
        #grid(
            columns: 2,
            table(columns: 1, order, empty),
            table(columns: 6, draw, draw, ..array.range(10).map(_ => empty)),
        )
    ]
}

#let practice-empty() = {
    practice-kanji((
        character: " ",
        onyomi: " ",
        kunyomi: " ",
        meaning: " "
    ))
}

#let practice(kanji: "", category: none) = {
    if category != none {
        if categories-dict.at(category, default: none) == none {
            panic("invalid category", category)
        }
        for k in kanjis-categorised.categories.at(category) {
            practice-kanji(k)
        }
        return
    }

    let kanjis-list = kanji.clusters()
    if kanjis-list.len() == 0 {
        return
    }
    let kanjis-map = kanjis.fold((:), (acc, k) => {
        if kanjis-list.contains(k.character) {
            acc.insert(k.character, k)
        }
        acc
    })
    for k in kanjis-list {
        if k == " " {
            practice-empty()
        } else {
            practice-kanji(kanjis-map.at(k))
        }
    }
}
