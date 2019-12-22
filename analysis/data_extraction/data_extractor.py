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
    """
    Class that organized extraction of data from XML.
    """

    TYPE_EXTRACT_ALL = 'all'
    TYPE_EXTRACT_EX = 'ex'
    TYPE_EXTRACT_AM = 'am'

    samples = []

    @staticmethod
    def extract():
        """ Extract everything.

        convenience method that calls all extractions that are implemented.

        Returns:
            None: None
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

        abbreviation_marks = Extractor.get_abbreviation_marks_raw(xml_soup)
        abbreviation_mark_frequencies = Extractor.get_abbreviation_mark_frequencies(xml_soup)

        expansions = Extractor.get_expansions_raw(xml_soup)
        expansion_frequencies = Extractor.get_expansion_frequencies(xml_soup)

        abbreviations = Extractor.get_abbreviations_raw(xml_soup)
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
    def get_abbreviation_count(data):
        """Count abbreviations

        Count the number of abbreviations in an XML.

        Args:
            data (BeautifulSoup): XML data

        Returns:
            int: Number of abbreviations
        """

        return len(data.find_all('abbreviation'))

    @classmethod
    def get_character_count(cls, soup):
        """Get number of characters in XML.

        Counts all characters in XML data. <g> is counted as 1 character.

        Args:
            soup (Tag): XML data

        Returns:
            int: number of characters
        """
        tmp = copy.copy(soup)
        for g in tmp.find_all('g'):
            g.replace_with('^')
        text = tmp.get_text()
        return len(text)

    @staticmethod
    def write_to_csv(file, names, rows):
        """Writes data to CSV file.

        Writes a given set of data to a local file

        Args:
            file (str): File name
            names (list of str): Column names
            rows (list of list): Rows of data (each row must be a list of same length as `names`)

        Returns:
            None: None
        """

        path_prefix = "../tmp_data/"
        with open(path_prefix + file, mode='w', encoding='utf-8', newline='') as file:
            w = csv.writer(file)
            w.writerow(names)
            for row in rows:
                w.writerow(row)

    @staticmethod
    def get_word_frequencies(words_raw_rep, plot=False, print_no=0):
        """Get word frequencies.

        Get a word frequency distribution of a text of words in raw form.

        Args:
            words_raw_rep (list of str): Words in raw text format.
            plot (bool): Plot data if True. Default is False.
            print_no (int): Print most frequent words to console. If 0, nothing is printed.

        Returns:
            nltk.FreqDist: Frequency distribution of the words.
        """

        frequ = nltk.FreqDist(words_raw_rep)
        if plot:
            frequ.plot()
        if print_no > 0:
            print("Most frequent:")
            for w in frequ.most_common(print_no):
                print("   {}\t{}".format(w[1], w[0]))

        return frequ

    @staticmethod
    def get_page_count(data):
        """
        Count number of pages.
        Args:
            data (BeautifulSoup): XML data

        Returns:
            int: Number of pages
        """
        return len(data.find_all('page'))

    @staticmethod
    def get_line_count(data):
        """
        Count number of lines.
        Args:
            data (BeautifulSoup): XML data

        Returns:
            int: Number of lines
        """
        return len(data.find_all('line'))

    @staticmethod
    def get_word_count(data):
        """
        Count number of words.
        Args:
            data (BeautifulSoup): XML data

        Returns:
            int: Number of words
        """
        return len(data.find_all('w'))

    @staticmethod
    def resolve_glyph(w):
        """
        Change all glyphs from xml to raw representation.

        Args:
            w (Tag): Tag potentially containing a glyph.

        Returns:
            Tag: copy of the input Tag, where <g> is replaced with raw representation.
        """
        res = copy.copy(w)
        for glyph in res.find_all('g'):
            val = glyph['ref'][1:]
            glyph.string = '{' + val + '}'
            glyph.unwrap()
        return res

    @staticmethod
    def resolve_abbreviations(w, type):
        """
        Change all abbreviations from xml to raw representation.

        Args:
            w (Tag): Tag potentially containing an abbreviation.
            type (str): defines what information shall be retained.
                Can be 'am', 'ex' or 'all'.

        Returns:
            Tag: copy of the input Tag, where <abbreviation> is replaced with raw representation.
        """
        res = copy.copy(w)
        if res.name == 'abbreviation':
            Extractor.extract_abbreviation_contents(res, type)
        else:
            for abbr in res.find_all('abbreviation'):
                abbr.replace_with(Extractor.extract_abbreviation_contents(abbr, type))
        return res

    @staticmethod
    def extract_abbreviation_contents(abbr, type):
        """
        Extract contents of a single abbreviation.

        Args:
            abbr (Tag): the abbreviation
            type (str): defines what information shall be retained.
                Can be 'am', 'ex' or 'all'.

        Returns:
            str: raw representation of the abbreviation.
        """
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
        """Convert XML to raw.

        Resolves glyphs and abbreviations, then extracts text contents.
        (Seems to work on <w> level or below; longer sequences uncertain.)
        NB: If it returns None, that is usually, because it gets multiple strings,
        in which case `Tag.string` returns None.

        Args:
            w (Tag): XML data
            type (str): defines what information shall be retained.
                Can be 'am', 'ex' or 'all'.

        Returns:
            str: raw representation of XML
        """
        tmp = Extractor.resolve_glyph(w)
        tmp = Extractor.resolve_abbreviations(tmp, type)
        tmp.smooth()
        return tmp.string

    @staticmethod
    def get_words_raw_rep(file, type, replace_wordparts=True):
        """
        Gets all words as a list of raw strings.

        Args:
            file (BeautifulSoup): XML data
            type (str): defines what information shall be retained.
                Can be 'am', 'ex' or 'all'.
            replace_wordparts (bool): if true, wordparts are added to previous words. Default is True.
                Should be false, if line length is looked at, because wordparts end up in the previous line.

        Returns:
            list of str: raw words
        """
        file_tmp = copy.copy(file)
        if replace_wordparts:
            file_tmp = Extractor.replace_wordparts(file)
        # TODO: if replace_wordparts is False, treat them as words?
        # TODO: handle <pc>?
        ws = file_tmp.find_all('w')
        rws = [Extractor.make_raw(copy.copy(w), type).replace('\n', '') for w in ws]
        return rws

    @staticmethod
    def replace_wordparts(file):
        """
        Moves wordparts into previous words.

        Args:
            file (BeautifulSoup): XML data

        Returns:
            BeautifulSoup: Copy of input data, where wordparts have been moved to previous words.
        """
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
        """
        Strip XML data of whitespace-only nodes.

        Args:
            xml_soup (BeautifulSoup): XML Data

        Returns:
            BeautifulSoup: input data, without any NavigableString containing only whitespace.
        """
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
    def get_abbreviation_touples(cls):
        # TODO
        pass

    @classmethod
    def get_abbreviation_marks_raw(cls, soup):
        """
        Get all abbreviation marks as raw.

        Args:
            soup (BeautifulSoup): xml data

        Returns:
            list of str: abbreviation marks as raw
        """
        ams = soup.find_all('am')
        res = []
        for am in ams:
            res.append(cls.make_raw(am, cls.TYPE_EXTRACT_ALL))
        return res

    @classmethod
    def get_abbreviation_mark_frequencies(cls, soup):
        """
        Get frequency distribution of abbreviation marks.

        Args:
            soup (BeautifulSoup): xml data

        Returns:
            nltk.FreqDist: Frequency distribution of abbreviation marks.
        """
        ams = cls.get_abbreviation_marks_raw(soup)
        frequs = cls.get_word_frequencies(ams, print_no=5)
        return frequs

    @classmethod
    def get_expansions_raw(cls, soup):
        """
        Get all expansions as raw.

        Args:
            soup (BeautifulSoup): xml data

        Returns:
            list of str: expansions as raw
        """
        ams = soup.find_all('ex')
        res = []
        for am in ams:
            res.append(cls.make_raw(am, cls.TYPE_EXTRACT_ALL))
        return res

    @classmethod
    def get_expansion_frequencies(cls, soup):
        """
        Get frequency distribution of expansions.

        Args:
            soup (BeautifulSoup): xml data

        Returns:
            nltk.FreqDist: Frequency distribution of expansions.
        """
        exs = cls.get_expansions_raw(soup)
        frequs = cls.get_word_frequencies(exs, print_no=5)
        return frequs

    @classmethod
    def get_abbreviations_raw(cls, soup):
        """
        Get all abbreviations as raw.

        Args:
            soup (BeautifulSoup): xml data

        Returns:
            list of str: abbreviations as raw
        """
        ams = soup.find_all('abbreviation')
        res = []
        for am in ams:
            tmp = cls.resolve_glyph(am)
            res.append(cls.extract_abbreviation_contents(tmp, cls.TYPE_EXTRACT_ALL))
        return res

    @classmethod
    def get_abbreviation_frequencies(cls, soup):
        """
        Get frequency distribution of abbreviations.

        Args:
            soup (BeautifulSoup): xml data

        Returns:
            nltk.FreqDist: Frequency distribution of abbreviations.
        """
        abbreviations = cls.get_abbreviations_raw(soup)
        frequs = cls.get_word_frequencies(abbreviations, print_no=5)
        return frequs

    @classmethod
    def get_lines(cls, data):
        """
        Get a list of all lines in a document.

        Args:
            data (BeautifulSoup): XML data

        Returns:
            list of Tag: all <line> tags.
        """
        tmp = copy.copy(data)
        cls.replace_wordparts(tmp)
        return tmp.find_all('line')

    @staticmethod
    def extract_page_overview_info():
        """
        Extracts page overview information and writes it to a CSV file.

        Returns:
            None: None
        """
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
    def extract_data_by_line():
        """Extract line data.

        Extract number of words, characters and abbreviations for each line.
        Write data to CSV file.

        Returns:
            None: None
        """
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
    def extract_abbreviations(cls):
        # TODO: consider stop-list
        names = ["sample", "sample_name", "am", "ex"]
        rows = []
        for section_index, section in enumerate(Extractor.samples):
            section_name = section[0]
            data = section[1]
            abbreviations = Extractor.get_abbreviation_touples()
            # TODO
            # for i, line in enumerate(lines):
            #     row = [section_index, section_name, i, Extractor.get_word_count(line),
            #            Extractor.get_character_count(line), Extractor.get_abbreviation_count(line)]
            #     rows.append(row)
        Extractor.write_to_csv('abbreviations.csv', names, rows)


if __name__ == '__main__':
    Extractor.extract()
