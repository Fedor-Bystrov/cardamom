#!/bin/bash

DEPS_FOLDER=~/.tyr/deps

echo "Downloading Javelin"
echo "============================================================================="
wget -P $DEPS_FOLDER https://clojars.org/repo/javelin/javelin/3.8.1/javelin-3.8.1.jar

echo "Downloading SLF4J Simple"
echo "============================================================================="
wget -P $DEPS_FOLDER http://central.maven.org/maven2/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar
