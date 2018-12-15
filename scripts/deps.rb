require 'bundler/setup'
require 'nokogiri'
require 'faraday'
require 'yaml'

$deps_path = '~/.tyr/deps'
$filepath_pattern = /^(.+):(.+)@(.+)$/
$pom_filepath_prefix = 'https://search.maven.org/remotecontent?filepath='
$pom_param_pattern = /^\$\{(.+)\}$/

# Runs wget in a new subprocess and
# downloads file to $deps_path
# Params:
# +url+:: URL of file
def spawn_wget(url)
  IO.popen("wget -P #{$deps_path} #{url}") {|r| puts r.gets}
end

# Reads a project configuration file project.yaml
# located at the root of project folder
# Returns hash with project config
def read_project_file
  return YAML.load_file('project.yaml')
end

# Fetches pom.xml from maven repository for given dep_uri
# Returns pom xml object
# Params:
# +dep_uri+:: dependency uri from project.yaml dep entry
def fetch_pom(dep_uri)
# TODO заюзать faraday connection object 
# см. https://github.com/lostisland/faraday
  res = Faraday.get $pom_filepath_prefix + dep_uri
  return Nokogiri::XML(res.body) do |config|
    config.noblanks
  end
end

# Converts package.yml dep string to filepath for maven repository
# Returns maven filepath string
# +dep_uri+:: dependency uri from project.yaml dep entry
def dep_to_filepath(dep_uri)
  unless match = $filepath_pattern.match(dep_uri)
    raise "invalid dep uri: #{dep_uri}"
  end

  group1, group2, version = match.captures
  groupId = group1.gsub('.', '/')
  artifactId = group2.gsub('.', '/')
  return "#{groupId}/#{artifactId}/#{version}/#{artifactId}-#{version}.pom"
end

# Parses maven pom file and returns properties as ruby hash
def get_pom_properties(pom_doc)
  return pom_doc.css('properties').children.map {|c| [c.name, c.text]}.to_h
end

# Rejects all dependencies with test scope
# from dependecy nodes list
# Params:
# +dep_nodes+:: list of dependency xml nodes
def reject_test_deps(dep_nodes)
  return dep_nodes.reject {|d| d.css('scope').text == 'test'}
end

# Substitutes given placeholder string for maven property.
# Params:
# +text+:: string with placeholder
# +props+:: hash with properties from pom
def resolve_pom_property(text, props)
  if text.include? '$' and match = $pom_param_pattern.match(text)
    key, _ = match.captures
    return props.fetch(key)
  end

  return text
end

# Parses pom node and returns list of dependencies 
def get_pom_dependecies(pom_doc)
  props = get_pom_properties pom_doc
  deps = reject_test_deps pom_doc.css('dependencies//dependency')

  return deps.map do |dep|
    groupId = dep.at('groupId').text
    artifactId = dep.at('artifactId').text
    version = resolve_pom_property dep.at('version').text, props

    dep_to_filepath "#{groupId}:#{artifactId}@#{version}"
  end
end

project_deps = read_project_file['deps'][0]
pom = fetch_pom dep_to_filepath project_deps
dependencies = get_pom_dependecies pom

puts dependencies

# fetch_pom 'com/sparkjava/spark-core/2.7.2/spark-core-2.7.2.pom'
# spawn_wget('http://central.maven.org/maven2/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar')
