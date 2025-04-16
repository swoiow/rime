#!/usr/bin/env python
# -*- coding: utf-8 -*-

import datetime
import re
from pathlib import Path

import requests
from pypinyin import lazy_pinyin


OUT_DIR = Path("dist")
OUT_DIR.mkdir(parents=True, exist_ok=True)

__NAME__ = "xin_hua_zi_dian"
WORD_FREQUENCY = 50

fmt = f"""---
name: {__NAME__}
version: "{datetime.datetime.today().strftime('%Y.%m.%d')}"
sort: by_weight
use_preset_vocabulary: false
...

"""

dataset = {
    "ci.json": "https://github.com/pwxcoo/chinese-xinhua/raw/refs/heads/master/data/ci.json",
    "idiom.json": "https://github.com/pwxcoo/chinese-xinhua/raw/refs/heads/master/data/idiom.json",
    "word.json": "https://github.com/pwxcoo/chinese-xinhua/raw/refs/heads/master/data/word.json",
}


def remove_tones(pinyin: str) -> str:
    tone_map = {
        'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
        'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
        'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
        'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
        'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
        'ǖ': 'ü', 'ǘ': 'ü', 'ǚ': 'ü', 'ǜ': 'ü',
        'ü': 'ü', 'ń': 'n', 'ň': 'n', 'ǹ': 'n',
        'ḿ': 'm'
    }
    pattern = re.compile("|".join(tone_map))
    return pattern.sub(lambda x: tone_map[x.group()], pinyin)


def download_json(url: str) -> list:
    response = requests.get(url)
    response.raise_for_status()
    return response.json()


def handle_idiom(data: list) -> list:
    return [(item["word"], remove_tones(item["pinyin"])) for item in data]


def handle_words(data: list) -> list:
    return [(item["ci"], " ".join(lazy_pinyin(item["ci"]))) for item in data]


def handle_hans(data: list) -> list:
    return [(item["word"], remove_tones(item["pinyin"])) for item in data]


def dict_without_pinyin():
    filter_words_rule = re.compile(r"[,.\+\-，。a-zA-Z]+")

    idioms = handle_idiom(download_json(dataset["idiom.json"]))
    words = handle_words(download_json(dataset["ci.json"]))
    hans = handle_hans(download_json(dataset["word.json"]))

    combined = idioms + words + hans
    unique_sorted = sorted(set(combined), key=lambda x: x[0])

    with open(OUT_DIR / f"{__NAME__}.dict.yaml", "w", encoding="utf8") as wf:
        wf.write(
            fmt +
            "\n".join(
                f"{word}\t{pinyin}\t{WORD_FREQUENCY}"
                for word, pinyin in unique_sorted
                if not re.findall(filter_words_rule, word)
            )
        )

    return unique_sorted


if __name__ == '__main__':
    dict_without_pinyin()
