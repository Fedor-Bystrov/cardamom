require 'bundler/setup'
require 'faraday'
require 'yaml'

$deps_path = '~/.tyr/deps'
$filepath_pattern = /^([a-zA-Z]+\.[a-zA-Z]+):([\w\W]+)@(\d+\.\d+\.\d+)$/
$pom_filepath_prefix = 'https://search.maven.org/remotecontent?filepath='

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

# Fetches pom.xml from maven repository for given dep_ur
# Returns pom xml object
# Params:
# +dep_uri+:: dependency uri from project.yaml dep entry
def fetch_pom(dep_uri)
  res = Faraday.get $pom_filepath_prefix + dep_uri
  puts res.body
end

# Converts package.yml dep string to filepath for maven repository
# Returns maven filepath string
# +dep_uri+:: dependency uri from project.yaml dep entry
def dep_to_filepath(dep_uri)
  if match = $filepath_pattern.match(dep_uri)
    groupId, artifact, version = match.captures
    return "#{groupId.sub('.', '/')}/#{artifact}/#{version}/#{artifact}-#{version}.pom"
  else
    raise "invalid dep_uri: #{dep_uri}"
  end
end

# TODO заюзать faraday connection object см. https://github.com/lostisland/faraday
# TODO парсить pom в xml!

#puts fetch_pom dep_to_filepath read_project_file['deps'][0]
# fetch_pom 'com/sparkjava/spark-core/2.7.2/spark-core-2.7.2.pom'
# spawn_wget('http://central.maven.org/maven2/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar')
