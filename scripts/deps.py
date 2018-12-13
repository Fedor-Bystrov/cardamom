import subprocess
import requests
import yaml
import re

from xml.etree import ElementTree

deps_path = '/Users/fbystrov/.tyr/deps'

# Maven
# https://search.maven.org/classic/#api
dep_pattern = re.compile(r'^([a-zA-Z]+\.[a-zA-Z]+):([\w\W]+)@(\d+\.\d+\.\d+)$')
filepath_url = 'https://search.maven.org/remotecontent?filepath={}'


def spawn_wget(url: str) -> int:
    result = subprocess.run(['wget', '-P', deps_path, url])
    return result.returncode


def get_deps() -> list:
    with open('../project.yaml', 'r') as f:
        return yaml.load(f)['deps']


def get_maven_pom(row: str) -> ElementTree:
    r = requests.get(filepath_url.format(row))
    return ElementTree.fromstring(r.text)


def run():
    for dep in get_deps():
        res = dep_pattern.match(dep)
        print('groupId:', res.group(1))
        print('artifact', res.group(2))
        print('version:', res.group(3))

        pom = get_maven_pom('{groupId}/{artifact}/{version}/{artifact}-{version}.pom'.format(
            groupId=res.group(1).replace('.', '/'),
            artifact=res.group(2),
            version=res.group(3)))
        print(pom)


if __name__ == '__main__':
    run()
