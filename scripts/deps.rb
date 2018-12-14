require 'yaml'

$deps_path = '~/.tyr/deps'

# Runs wget in a new subprocess
# Params:
# +url+:: URL of file
def spawn_wget(url)
  IO.popen("wget -P #{$deps_path} #{url}") { |f| puts f.gets}
end

# Reads a project configuration file project.yaml
# located at the root of project folder
# Returns hash with project config
def read_project_file
  return YAML.load_file('project.yaml')
end


#puts read_project_file['deps']
#spawn_wget('http://central.maven.org/maven2/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar')
