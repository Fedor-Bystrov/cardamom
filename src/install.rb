require 'yaml'
require 'set'

require_relative 'mvn'
require_relative 'dep'
require_relative 'wget'

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

    puts '================================================'
    puts 'Downloading jars'
    puts '================================================'
    @@deps.each do |dep|
      # TODO refactor and fix bug with sl4fj dependency for jetty
      WGET::run("~/.cardamom/deps/#{dep.artifactId}-#{dep.version}.jar", "https://search.maven.org/remotecontent?filepath=#{dep.filepath}.jar")
    end

  end

  def self.recuriseve_fetch_deps(pom)
    if pom.deps.length == 0
      return
    end

    pom.deps.reject {|dep| @@deps.include? dep}.map do |dep|
      @@deps.add dep
      pom_ = MVN::fetch_pom dep
      # puts pom_
      recuriseve_fetch_deps pom_
    end
  end
end

INSTALL::init
