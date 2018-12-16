require 'yaml'
require 'set'

require_relative 'mvn'
require_relative 'dep'

module INSTALL
  @@deps_path = '~/.cardamom/deps'
  @@dep_pattern = /^(.+):([^@]+)(?:@(.*)$|$)/
  @@deps = Set.new

  def self.init
    puts 'Starting project initialization process'

    puts 'Reading project.yaml'
    project_yaml = YAML.load_file('project.yaml')

    puts '================================================'
    puts 'Resolving project dependencies'
    puts '================================================'
    project_deps = project_yaml['deps'].map do |dep|
      unless match = @@dep_pattern.match(dep)
        raise 'Cannot match project dep %s' % dep
      end

      groupId, artifactId, version = match.captures

      if version.nil?
        puts "Finding latest version for #{groupId}:#{artifactId}"
        version = MVN::find_latest_version(groupId, artifactId)
      end

      DEP::new(groupId, artifactId, version)
    end

    puts '================================================'
    puts 'Fetching poms for dependencies'
    puts '================================================'
    project_poms = project_deps.reject {|dep| @@deps.include? dep}.map do |dep|
      @@deps.add dep
      puts "Fetching pom for #{dep}"
      MVN::fetch_pom dep
    end

    project_poms.map do |pom|
      recuriseve_fetch_deps pom
    end

    puts "Dependencies: #{@@deps.to_set.length}"
  end

  def self.recuriseve_fetch_deps(pom)
    if pom.deps.length == 0
      return
    end

    pom.deps.reject {|dep| @@deps.include? dep}.map do |dep|
      @@deps.add dep
      recuriseve_fetch_deps MVN::fetch_pom dep
    end
  end
end

INSTALL::init


# 1. Собираем все зависимости, резолвим версии если не указаны
#    Зависимости из project.yml -> зависимости зависемостей из project.yml и т.д
#    В итоге должно получится (дерево или сет?) зависимостей
# 2. Скачиваем зависимости
# 3. Сохраняем результать в project.lock (например как в Pipfile.lock, посмотреть на yarn.lock)
# 4. Не плохо бы проверять хэши
# 5. Нужно ли хранить список модулей их имена и то чтот они экспортят, реквайрят?
# 6. Переехать на формат com.sparkjava:spark-core:2.7.2
#
# File.open("coffee.yml", "w") { |file| file.write(recipe.to_yaml) }
# File.write('/tmp/test.yml', d.to_yaml)
# YAML.dump(project_poms)
# можно ли заюзать https://search.maven.org/artifact/org.powermock/powermock-api-mockito/1.6.6/jar ??
