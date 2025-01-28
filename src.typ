#let kanjis = cbor("data/kanjiapi_full.cbor")

#let show-strokes(k) = {
    text(font: "KanjiStrokeOrders", size: 5em)[#k]
}

#let show-draw(k) = {
    text(font: "YOzFontN-StdN-R", size: 5em)[#k]
}

#let practice-kanji(key, kanji) = {
    set box(width: 5em, height: 5em)

    let empty = box(inset: (y: 5pt))
    let order = box[#show-strokes(key)]
    let draw = box(inset: (y: 5pt))[
        #set text(fill: gray)
        #show-draw(key)
    ]
    let opt(name, value, breaked: false) = {
        [#strong[#name]: #value]
        if breaked {
            linebreak()
        }
    }
    box(width: auto, height: auto)[
        #strong("Meaning"): #kanji.meanings.join(", ") \
        #opt("Kun", kanji.kun.join("、"), breaked: true)
        #opt("On", kanji.on.join("、"))
        #table(
            columns: 7,
            stroke: (x, y) => if x == 0 {
                (right: 1pt)
            } else {
                1pt
            },
            table.cell(rowspan: 2, order),
            draw,
            draw,
            ..array.range(10).map(_ => empty),
        )
    ]
}

#let practice-empty() = {
    practice-kanji("", (
        on: ("",),
        kun: ("",),
        meanings: ("",)
    ))
}

#let practice(kanji) = {
    if type(kanji) != str {
        set text(fill: red)
        [Warning: you should pass string]
        return
    }
    let kanjis-list = kanji.clusters()
    if kanjis-list.len() == 0 {
        return
    }
    let missing = ()
    for k in kanjis-list {
        if k == " " {
            practice-empty()
        } else if k in kanjis {
            practice-kanji(k, kanjis.at(k))
        } else {
            missing.push(k)
        }
    }
    if missing.len() > 0 {
        set text(fill: red)
        [Warning: missing kanjis #missing.join()]
    }
}
