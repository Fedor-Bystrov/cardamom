def spawn_wget(url)
  IO.popen("wget -P ~/.tyr/deps #{url}") { |f| puts f.gets}
end

spawn_wget('http://central.maven.org/maven2/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar')
