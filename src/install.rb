require 'yaml'
require 'set'

require_relative 'mvn'
require_relative 'dep'

module INSTALL
  @@deps_path = '~/.cardamom/deps'
  @@dep_pattern = /^(.+):([^@]+)(?:@(.*)$|$)/

  def self.init
    project_yaml = YAML.load_file('project.yaml')
    project_deps = project_yaml['deps'].map do |dep|
      unless match = @@dep_pattern.match(dep)
        raise 'Cannot match project dep %s' % dep
      end

      groupId, artifactId, version = match.captures

      if version.nil?
        version = MVN::find_latest_version(groupId, artifactId)
      end

      DEP::new(groupId, artifactId, version)
    end

    project_poms = project_deps.map do |dep|
      MVN::fetch_pom dep
    end

    puts project_poms
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
