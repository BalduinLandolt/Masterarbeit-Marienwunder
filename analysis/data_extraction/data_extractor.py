from lxml import etree
from bs4 import BeautifulSoup


class DataExtractor:

    @staticmethod
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
        pg_count = DataExtractor.get_page_count(xml_soup)
        print('Number of pages: {}'.format(pg_count))

        # get line count
        l_count = DataExtractor.get_line_count(xml_soup)
        print('Number of lines: {}'.format(l_count))

        # get word count
        w_count = DataExtractor.get_word_count(xml_soup)
        print('Number of words: {}'.format(w_count))

        # get average words per line
        av_words_per_line = w_count / l_count
        print('Average words per line: {}'.format(av_words_per_line))

        # get words with mark-up
        words_xml_rep = DataExtractor.get_words_xml_rep(xml_soup)


    @staticmethod
    def load_file(path):
        return etree.parse(path)

    @staticmethod
    def get_page_count(file):
        pbs = file.find_all('pb')
        #print(pbs)
        return len(pbs)

    @staticmethod
    def get_line_count(file):
        lbs = file.find_all('lb')
        #print(lbs)
        return len(lbs)

    @staticmethod
    def get_word_count(file):
        ws = file.find_all('w')
        #print(ws)
        return len(ws)

    @staticmethod
    def get_words_xml_rep(file):
        ws = [w.contents for w in file.find_all('w')]
        print(ws)
        return ws


if __name__ == '__main__':
    DataExtractor.extract()
