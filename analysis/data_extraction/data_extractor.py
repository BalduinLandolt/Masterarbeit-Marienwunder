"""
Balduin Landolt (2019)
Licensed under GNU AGPL license. See license file in the root of the repository.
"""

from lxml import etree
from bs4 import BeautifulSoup
from bs4.element import Tag, NavigableString
import copy
import nltk
import csv


class Extractor:
    TYPE_EXTRACT_ALL = 'all'
    TYPE_EXTRACT_EX = 'ex'
    TYPE_EXTRACT_AM = 'am'

    samples = []

    @staticmethod
    def extract():
        """
        convenience method that calls all extractions that are implemented.

        :return: None
        """

        # load xml file
        with open('../../transcription/transcriptions/transformed/part_01_transformed.xml', encoding='utf-8') as file:
            xml_soup = BeautifulSoup(file, features='lxml')
            xml_soup = Extractor.strip_whitespace(xml_soup)
            Extractor.samples.append(("part_01__p1ff", xml_soup))
        with open('../../transcription/transcriptions/transformed/part_02_transformed.xml', encoding='utf-8') as file:
            xml_soup = BeautifulSoup(file, features='lxml')
            xml_soup = Extractor.strip_whitespace(xml_soup)
            Extractor.samples.append(("part_02__p473ff", xml_soup))
            # TODO: make this dynamic

        cls = Extractor
        xml_soup = copy.copy(Extractor.samples[0][1])
        xml_soup.html.body.append(copy.copy(Extractor.samples[1][1].html.body.xml))

        # get page count
        pg_count = Extractor.get_page_count(xml_soup)
        print('Number of pages: {}'.format(pg_count))

        # get line count
        l_count = Extractor.get_line_count(xml_soup)
        print('Number of lines: {}'.format(l_count))

        # get word count
        w_count = Extractor.get_word_count(xml_soup)
        print('Number of words: {}'.format(w_count))

        # get average words per line
        av_words_per_line = w_count / l_count
        print('Average words per line: {}'.format(av_words_per_line))

        # get words with minimal raw mark-up
        words_raw_rep = Extractor.get_words_raw_rep(xml_soup, Extractor.TYPE_EXTRACT_ALL)
        raw_word_frequencies = Extractor.get_word_frequencies(words_raw_rep, plot=False, print_no=5)

        # get words expansion-only
        words_raw_rep_ex_only = Extractor.get_words_raw_rep(xml_soup, Extractor.TYPE_EXTRACT_EX)

        # get words abbreviation-only
        words_raw_rep_am_only = Extractor.get_words_raw_rep(xml_soup, Extractor.TYPE_EXTRACT_AM)

        abbreviation_marks = Extractor.get_abbreviation_marks(xml_soup)
        abbreviation_mark_frequencies = Extractor.get_abbreviation_mark_frequencies(xml_soup)

        expansions = Extractor.get_expansions(xml_soup)
        expansion_frequencies = Extractor.get_expansion_frequencies(xml_soup)

        abbreviations = Extractor.get_abbreviations(xml_soup)
        abbreviation_frequencies = Extractor.get_abbreviation_frequencies(xml_soup)

        # Data export to CSV
        # ------------------

        # most frequent stuff
        Extractor.write_to_csv("most_frequent_words.csv", ["word", "frequency"], raw_word_frequencies.most_common())
        Extractor.write_to_csv("most_frequent_abbreviation_marks.csv", ["abbreviation_mark", "frequency"],
                               abbreviation_mark_frequencies.most_common())
        Extractor.write_to_csv("most_frequent_expansions.csv", ["expansion", "frequency"],
                               expansion_frequencies.most_common())
        Extractor.write_to_csv("most_frequent_abbreviations.csv", ["abbreviation", "frequency"],
                               abbreviation_frequencies.most_common())

        # overview
        Extractor.extract_page_overview_info()

        # data by line
        Extractor.extract_data_by_line()

        # abbreviation marks
        Extractor.extract_abbreviations()

        # TODO: ...

    @staticmethod
    def get_abbreviation_count(file):
        return len(file.find_all('abbreviation'))

    @staticmethod
    def extract_page_overview_info():
        # TODO: could extraction be more generic, and with arguments to specify?
        field_names = ["sample", "sample_name", "no_pages", "no_lines", "no_words", "no_characters", "no_abbreviations"]
        rows = []
        for section_index, section in enumerate(Extractor.samples):
            section_name = section[0]
            data = section[1]
            row = [section_index, section_name, Extractor.get_page_count(data), Extractor.get_line_count(data),
                   Extractor.get_word_count(data), Extractor.get_character_count(data),
                   Extractor.get_abbreviation_count(data)]
            rows.append(row)
        Extractor.write_to_csv("page_overview.csv", field_names, rows)

    @staticmethod
    def write_to_csv(file, names, rows):
        path_prefix = "../tmp_data/"
        with open(path_prefix + file, mode='w', encoding='utf-8', newline='') as file:
            w = csv.writer(file)
            w.writerow(names)
            for row in rows:
                w.writerow(row)

    @staticmethod
    def get_word_frequencies(words_raw_rep, plot=False, print_no=0):
        frequ = nltk.FreqDist(words_raw_rep)
        if plot:
            frequ.plot()
        if print_no > 0:
            print("Most frequent:")
            for w in frequ.most_common(print_no):
                print("   {}\t{}".format(w[1], w[0]))

        return frequ

    @staticmethod
    def get_page_count(file):
        pbs = file.find_all('page')
        # print(pbs)
        return len(pbs)

    @staticmethod
    def get_line_count(file):
        lbs = file.find_all('line')
        # print(lbs)
        return len(lbs)

    @staticmethod
    def get_word_count(file):
        ws = file.find_all('w')
        # print(ws)
        return len(ws)

    @staticmethod
    def resolve_glyph(w):
        res = copy.copy(w)
        for glyph in res.find_all('g'):
            val = glyph['ref'][1:]
            glyph.string = '{' + val + '}'
            glyph.unwrap()
        return res

    @staticmethod
    def resolve_abbreviations(w, type):
        res = copy.copy(w)
        if res.name == 'abbreviation':
            Extractor.extract_abbreviation_contents(res, type)
        else:
            for abbr in res.find_all('abbreviation'):
                abbr.replace_with(Extractor.extract_abbreviation_contents(abbr, type))
        return res

    @staticmethod
    def extract_abbreviation_contents(abbr, type):
        abbr.smooth()
        ex = abbr.ex.string or ''
        infix = abbr.infix.string or ''
        am = abbr.am.string or ex
        am = am.replace('{', '')
        am = am.replace('}', '')
        if type == Extractor.TYPE_EXTRACT_ALL:
            rw = '({};{};{})'.format(ex, infix, am)
        elif type == Extractor.TYPE_EXTRACT_EX:
            rw = '({})'.format(ex)
        elif type == Extractor.TYPE_EXTRACT_AM:
            rw = '({})'.format(am)
        return rw

    @staticmethod
    def make_raw(w, type):
        tmp = Extractor.resolve_glyph(w)
        tmp = Extractor.resolve_abbreviations(tmp, type)
        tmp.smooth()
        return tmp.string

    @staticmethod
    def get_words_raw_rep(file, type, replace_wordparts=True):
        file_tmp = copy.copy(file)
        if replace_wordparts:
            file_tmp = Extractor.replace_wordparts(file)
        ws = file_tmp.find_all('w')
        rws = [Extractor.make_raw(copy.copy(w), type).replace('\n', '') for w in ws]
        return rws

    @staticmethod
    def replace_wordparts(file):
        res = copy.copy(file)
        for wp in res.find_all('wordpart'):
            prev_line = wp.parent.previous_sibling
            if prev_line is None:
                continue
            # TODO: ensure in transformation, that that doesn't happen (i.e. <wordpart/>) at page beginning
            words = prev_line.find_all('w')
            s = Extractor.make_raw(wp, Extractor.TYPE_EXTRACT_ALL)
            words[-1].append(s)
            wp.decompose()
        return res

    @staticmethod
    def strip_whitespace(xml_soup):
        for e in xml_soup.descendants:
            if isinstance(e, NavigableString):
                next = e.next_element
                if e.isspace():
                    e.replace_with('')
                else:
                    e.replace_with(e.replace('\n', ''))
                e.next_element = next
        return xml_soup

    @classmethod
    def get_abbreviation_marks(cls, soup):
        ams = soup.find_all('am')
        res = []
        for am in ams:
            res.append(cls.make_raw(am, cls.TYPE_EXTRACT_ALL))
        return res

    @classmethod
    def get_abbreviation_mark_frequencies(cls, soup):
        ams = cls.get_abbreviation_marks(soup)
        frequs = cls.get_word_frequencies(ams, print_no=5)
        return frequs

    @classmethod
    def get_expansions(cls, soup):
        ams = soup.find_all('ex')
        res = []
        for am in ams:
            res.append(cls.make_raw(am, cls.TYPE_EXTRACT_ALL))
        return res

    @classmethod
    def get_expansion_frequencies(cls, soup):
        exs = cls.get_expansions(soup)
        frequs = cls.get_word_frequencies(exs, print_no=5)
        return frequs

    @classmethod
    def get_abbreviations(cls, soup):
        ams = soup.find_all('abbreviation')
        res = []
        for am in ams:
            tmp = cls.resolve_glyph(am)
            res.append(cls.extract_abbreviation_contents(tmp, cls.TYPE_EXTRACT_ALL))
        return res

    @classmethod
    def get_abbreviation_frequencies(cls, soup):
        abbreviations = cls.get_abbreviations(soup)
        frequs = cls.get_word_frequencies(abbreviations, print_no=5)
        return frequs

    @staticmethod
    def extract_data_by_line():
        names = ["sample", "sample_name", "line_number", "no_words", "no_characters", "no_abbreviations"]
        rows = []
        for section_index, section in enumerate(Extractor.samples):
            section_name = section[0]
            data = section[1]
            lines = Extractor.get_lines(data)
            for i, line in enumerate(lines):
                row = [section_index, section_name, i, Extractor.get_word_count(line),
                       Extractor.get_character_count(line), Extractor.get_abbreviation_count(line)]
                rows.append(row)
        Extractor.write_to_csv('data_by_line.csv', names, rows)

    @classmethod
    def get_lines(cls, data):
        tmp = copy.copy(data)
        cls.replace_wordparts(tmp)
        return tmp.find_all('line')

    @classmethod
    def get_character_count(cls, soup):
        tmp = copy.copy(soup)
        for g in tmp.find_all('g'):
            g.replace_with('^')
        text = tmp.get_text()
        return len(text)

    @classmethod
    def extract_abbreviations(cls):
        # TODO: consider stop-list
        names = ["sample", "sample_name", "am", "ex"]
        rows = []
        for section_index, section in enumerate(Extractor.samples):
            section_name = section[0]
            data = section[1]
            abbreviations = Extractor.get_abbreviation_touples()
            # for i, line in enumerate(lines):
            #     row = [section_index, section_name, i, Extractor.get_word_count(line),
            #            Extractor.get_character_count(line), Extractor.get_abbreviation_count(line)]
            #     rows.append(row)
        Extractor.write_to_csv('abbreviations.csv', names, rows)

    @classmethod
    def get_abbreviation_touples(cls):
        pass


if __name__ == '__main__':
    Extractor.extract()
