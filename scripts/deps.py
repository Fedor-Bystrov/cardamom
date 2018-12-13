import subprocess

deps_path = '/Users/fbystrov/.tyr/deps'
path = 'http://central.maven.org/maven2/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar'


def spawn_wget(url: str) -> int:
    result = subprocess.run(['wget', '-P', deps_path, url])
    return result.returncode

spawn_wget(path)


# maven api guide:
# https://search.maven.org/classic/#api
def search_maven():
    prefix = 'http://search.maven.org/#search|ga|1|guice'