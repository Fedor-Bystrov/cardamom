require 'yaml'
require 'set'

require_relative 'mvn'

$deps_path = '~/.cardamom/deps'

# Reads a project configuration file project.yaml
# located at the root of project folder
# Returns hash with project config
def read_project_file
  return YAML.load_file('project.yaml')
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

def collect_deps(dep_uri)
  puts dep_uri
  # puts dep_to_filepath dep_uri
end

# 1. Резолвим все зависимости указанные в project.yml
project_deps = read_project_file['deps'].map do |dep|
  puts dep
  dep
end

puts project_deps
# pom = fetch_pom dep_to_filepath project_deps
# pom_dep = get_pom_dependecies pom

# puts project_dependencies

# dependencies.each {|dep| puts $pom_filepath_prefix + dep}
# fetch_pom 'com/sparkjava/spark-core/2.7.2/spark-core-2.7.2.pom'
# spawn_wget('http://central.maven.org/maven2/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar')

# 1. Собираем все зависимости, резолвим версии если не указаны
#    Зависимости из project.yml -> зависимости зависемостей из project.yml и т.д
#    В итоге должно получится (дерево или сет?) зависимостей
# 2. Скачиваем зависимости
# 3. Сохраняем результать в project.lock (например как в Pipfile.lock, посмотреть на yarn.lock)
# 4. Не плохо бы проверять хэши
# 5. Нужно ли хранить список модулей их имена и то чтот они экспортят, реквайрят?
