from lxml import etree
from bs4 import BeautifulSoup
from bs4.element import Tag, NavigableString
import copy
import nltk


def extract():
    """
    convenience method, that calls all extractions that are implemented.

    :return: None
    """
    print('do stuff!')

    # load xml file
    with open('../../transcription/transcriptions/part_01.xml', encoding='utf-8') as file:
        xml_soup = BeautifulSoup(file, features='lxml')

    #print(xml_soup)

    #xml_file = DataExtractor.load_file('../../transcription/transcriptions/part_01.xml')
    #s = etree.tostring(xml_file, pretty_print=True).decode("utf-8")
    #print(s)

    # get page count
    pg_count = get_page_count(xml_soup)
    print('Number of pages: {}'.format(pg_count))

    # get line count
    l_count = get_line_count(xml_soup)
    print('Number of lines: {}'.format(l_count))

    # get word count
    w_count = get_word_count(xml_soup)
    print('Number of words: {}'.format(w_count))

    # get average words per line
    av_words_per_line = w_count / l_count
    print('Average words per line: {}'.format(av_words_per_line))

    # get words with minimal xml mark-up
    words_xml_rep = get_words_xml_rep(xml_soup)

    # get words with minimal raw mark-up
    words_raw_rep = get_words_raw_rep(xml_soup)
    raw_word_frequencies = get_word_frequencies(words_raw_rep)
    raw_word_frequencies.plot()
    print("Most frequent words:")
    for w in raw_word_frequencies.most_common(20):
        print("   {}\t{}".format(w[1], w[0]))


def get_word_frequencies(words_raw_rep):
    frequ = nltk.FreqDist(words_raw_rep)
    return frequ


def load_file(path):
    return etree.parse(path)


def get_page_count(file):
    pbs = file.find_all('pb')
    #print(pbs)
    return len(pbs)


def get_line_count(file):
    lbs = file.find_all('lb')
    #print(lbs)
    return len(lbs)


def get_word_count(file):
    ws = file.find_all('w')
    #print(ws)
    return len(ws)


def clean_up(word):
    leave_in = ['am', 'abbr', 'ex', 'expan', 'choice', 'g']
    for e in word.descendants:
        if isinstance(e, Tag):
            if e.name not in leave_in:
                e.unwrap()
                return clean_up(word)
    word.smooth()
    return word


def get_words_xml_rep(file):
    ws = [clean_up(w).contents for w in file.find_all('w')]
    #print(ws)
    return ws


def resolve_glyph(w):
    for glyph in w.find_all('g'):
        val = glyph['ref'][1:]
        glyph.string = '{'+val+'}'
        glyph.unwrap()


def resolve_choice(ch):
    am = ch.abbr.am.string or ''
    am = am.replace('{', '')
    am = am.replace('}', '')

    infixi = ch.abbr.contents
    infix = ''
    if isinstance(infixi[0], NavigableString):
        infix = infixi[0]

    ex = ch.expan.ex.string or ''

    return '({};{};{})'.format(ex, infix, am)


def resolve_abbreviation(w):
    # TODO: consider: can there be choices that aren't abbreviations
    for ch in w.find_all('choice'):
        rw = resolve_choice(ch)
        ch.replace_with(rw)


def make_raw(w):
    resolve_glyph(w)
    resolve_abbreviation(w)
    w.smooth()
    return w.string


def get_words_raw_rep(file):
    ws = [clean_up(w) for w in file.find_all('w')]
    rws = [make_raw(copy.copy(w)) for w in ws]
    #print(ws)
    #print(rws)
    return rws


if __name__ == '__main__':
    extract()
