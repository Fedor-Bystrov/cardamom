require 'yaml'
require 'set'

require_relative 'mvn'
require_relative 'dep'

module INSTALL
  @@deps_path = '~/.cardamom/deps'
  @@dep_pattern = /^(.+):([^@]+)(?:@(.*)$|$)/

  def self.init
    project_yaml = YAML.load_file('../project.yaml')
    project_deps = project_yaml['deps'].map do |dep|
      dep
    end
    # TODO парсить зависимости из project_yaml в объекты,
    # подтягивать версии если не указаны
    # Далее рекурсивно

    puts project_deps
  end
end


# 1. Собираем все зависимости, резолвим версии если не указаны
#    Зависимости из project.yml -> зависимости зависемостей из project.yml и т.д
#    В итоге должно получится (дерево или сет?) зависимостей
# 2. Скачиваем зависимости
# 3. Сохраняем результать в project.lock (например как в Pipfile.lock, посмотреть на yarn.lock)
# 4. Не плохо бы проверять хэши
# 5. Нужно ли хранить список модулей их имена и то чтот они экспортят, реквайрят?
