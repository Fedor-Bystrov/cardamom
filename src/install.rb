require 'yaml'
require 'set'
require_relative 'mvn'

module INSTALL
  @@deps_path = '~/.cardamom/deps'

  def self.init
    puts 'init!'
    project_yaml = YAML.load_file('../project.yaml')
    project_deps = project_yaml['deps'].map do |dep|
      dep
    end

    puts project_deps
  end
end



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
