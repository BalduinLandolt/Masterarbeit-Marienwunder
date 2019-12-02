"""
Balduin Landolt (2019)
Licensed under GNU AGPL license. See license file in the root of the repository.
"""

from lxml import etree
from bs4 import BeautifulSoup
from bs4.element import Tag, NavigableString
import copy
import nltk
import matplot
import csv


def extract():
    """
    convenience method, that calls all extractions that are implemented.

    :return: None
    """

    samples = []

    # load xml file
    with open('../../transcription/transcriptions/part_01.xml', encoding='utf-8') as file:
        xml_soup = BeautifulSoup(file, features='lxml')
        samples.append(("part_01__p1ff", xml_soup))
        # TODO: make this dynamic

    # print(xml_soup)

    # xml_file = DataExtractor.load_file('../../transcription/transcriptions/part_01.xml')
    # s = etree.tostring(xml_file, pretty_print=True).decode("utf-8")
    # print(s)

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
    words_raw_rep = get_words_raw_rep(xml_soup, 'all')
    raw_word_frequencies = get_word_frequencies(words_raw_rep, plot=False, print_no=20)

    # get words expansion-only
    words_raw_rep_ex_only = get_words_raw_rep(xml_soup, 'ex')
    raw_word_frequencies = get_word_frequencies(words_raw_rep_ex_only, plot=False, print_no=20)

    # get words abbreviation-only
    words_raw_rep_am_only = get_words_raw_rep(xml_soup, 'am')
    raw_word_frequencies = get_word_frequencies(words_raw_rep_am_only, plot=False, print_no=20)

    # TODO: abbreviation-mark-frequencies
    # TODO: abbreviation-expansion-frequencies

    # TODO: Data export to CSV
    extract_page_overview_info(samples)
    extract_data_by_line(samples)

    # TODO: ...


def get_abbreviation_count(file):
    return len(file.find_all('abbr'))


def split_by_line(data):
    print(data)
    lbs = data.find_all("lb")
    lines = []
    for lb in lbs:
        nexts = []
        for sibling in lb.next_siblings:
            # TODO: find siblings up to next <lb>
            pass
        # TODO: collate them to a line, add to lines


    pass


def extract_data_by_line(samples):
    names = ["sample", "sample_name", "line_number", "no_words", "no_characters", "no_abbreviations"]
    rows = []
    for section_index, section in enumerate(samples):
        section_name = section[0]
        data = section[1]
        row = [section_index, section_name]
        lines = split_by_line(data)


def extract_page_overview_info(samples):
    # TODO: could extraction be more generic, and with arguments to specify?
    field_names = ["sample", "sample_name", "no_pages", "no_lines", "no_words", "no_abbreviations"]
    rows = []
    for section_index, section in enumerate(samples):
        section_name = section[0]
        data = section[1]
        row = [section_index, section_name, get_page_count(data), get_line_count(data),
               get_word_count(data), get_abbreviation_count(data)]
        rows.append(row)
    write_to_csv("page_overview.csv", field_names, rows)


def write_to_csv(file, names, rows):
    path_prefix = "../tmp_data/"
    with open(path_prefix + file, mode='w', encoding='utf-8', newline='') as file:
        w = csv.writer(file)
        w.writerow(names)
        for row in rows:
            w.writerow(row)
        # TODO: remove, once there are multiple samples
        w.writerow([999, "none", 1, 1, 1, 1])


def get_word_frequencies(words_raw_rep, plot, print_no):
    frequ = nltk.FreqDist(words_raw_rep)
    if plot:
        frequ.plot()
    if print_no > 0:
        print("Most frequent words:")
        for w in frequ.most_common(print_no):
            print("   {}\t{}".format(w[1], w[0]))

    return frequ


def load_file(path):
    return etree.parse(path)


def get_page_count(file):
    pbs = file.find_all('pb')
    # print(pbs)
    return len(pbs)


def get_line_count(file):
    lbs = file.find_all('lb')
    # print(lbs)
    return len(lbs)


def get_word_count(file):
    ws = file.find_all('w')
    # print(ws)
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
    # print(ws)
    return ws


def resolve_glyph(w):
    for glyph in w.find_all('g'):
        val = glyph['ref'][1:]
        glyph.string = '{' + val + '}'
        glyph.unwrap()


def resolve_choice(ch, type):
    am = ch.abbr.am.string or ''
    am = am.replace('{', '')
    am = am.replace('}', '')

    infixi = ch.abbr.contents
    infix = ''
    if isinstance(infixi[0], NavigableString):
        infix = infixi[0]

    ex = ch.expan.ex.string or ''

    if type == 'all':
        return '({};{};{})'.format(ex, infix, am)
    elif type == 'ex':
        return '({})'.format(ex)
    elif type == 'am':
        return '({})'.format(am)
    else:
        return '({};{};{})'.format(ex, infix, am)


def resolve_abbreviation(w, type):
    # TODO: consider: can there be choices that aren't abbreviations
    for ch in w.find_all('choice'):
        rw = resolve_choice(ch, type)
        ch.replace_with(rw)


def make_raw(w, type):
    resolve_glyph(w)
    resolve_abbreviation(w, type)
    w.smooth()
    return w.string


def get_words_raw_rep(file, type):
    ws = [clean_up(w) for w in file.find_all('w')]
    rws = [make_raw(copy.copy(w), type) for w in ws]
    return rws


if __name__ == '__main__':
    extract()
