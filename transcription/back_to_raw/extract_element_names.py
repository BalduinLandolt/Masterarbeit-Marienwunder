import lxml
from bs4 import BeautifulSoup

with open('all.xml', encoding='utf-8', mode='r') as file:
    soup = BeautifulSoup(file, features='lxml')

body = soup.find_all('text')

names = [e.name for e in body[0].descendants if e is not None and e.name is not None]

names = sorted(list(set(names)))
print(names)

with open('names.txt', encoding='utf-8', mode='w') as out:
    for name in names:
        out.write(f'{name}\n')
