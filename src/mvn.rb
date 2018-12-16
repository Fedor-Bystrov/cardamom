require 'bundler/setup'
require 'nokogiri'
require 'faraday'
require 'json'

require_relative 'dep'

module MVN
  @@srch_conn = Faraday.new(:url => 'https://search.maven.org')
  @@remotecontent_uri = '/remotecontent?filepath=%s.pom'
  @@select_uri = '/solrsearch/select?q=g:"%s"+AND+a:"%s"&rows=1&wt=json'

  # Fetches pom.xml from maven repository for given dependency
  # Returns pom object for given dependency
  # Params:
  # +dep+:: dependency object
  def self.fetch_pom(dep)
    res = @@srch_conn.get @@remotecontent_uri % dep.filepath
    return POM.new dep, res.body
  end

  # Finds latest version for dependency with provided
  # groupId and artifactiId
  # Params:
  # +groupId+:: dependency groupId
  # +artifactId+:: dependency artifactId
  def self.find_latest_version(groupId, artifactId)
    res = @@srch_conn.get @@select_uri % [groupId, artifactId]
    res_json = JSON::parse(res.body).fetch('response')
    return res_json.fetch('docs')[0].fetch('latestVersion')
  end

  class POM
    @@param_pattern = /^\$\{(.+)\}$/

    attr_reader :props, :deps, :version

    def initialize(dep, pom_xml)
      pom_doc = Nokogiri::XML(pom_xml) {|config| config.noblanks}
      @groupId = dep.groupId
      @artifactId = dep.artifactId
      @version = dep.version
      @props = parse_props pom_doc
      @deps = parse_deps pom_doc
    end

    def to_s
      return "POM{#{@groupId}, #{@artifactId}, #{@version}, #{@props}, #{@deps.map{|dep| dep.to_s}}}"
    end


      # Parses maven pom root node and returns properties as ruby hash
      def parse_props(pom_doc)
        return pom_doc.css('properties').children.map {|c| [c.name, c.text]}.to_h
      end

      # Parses pom node and returns list of all dependencies
      # in "groupdId:artifactId@version" format
      # Params:
      # +pom_doc+:: mvn pom root node
      def parse_deps(pom_doc)
        # ignoring test deps for now
        deps = pom_doc.css('dependencies//dependency').select { |dep|
           dep.at('scope').nil? or dep.at('scope').text != 'test'
        }

        return deps.collect do |dep|
          groupId = dep.at('groupId').text
          artifactId = dep.at('artifactId').text
          version_n = dep.at('version')
          scope_n = dep.at('scope')
          optional_n = dep.at('optional')

          DEP::new(groupId, artifactId,
                  version_n.nil?  ? @version : resolve_prop(version_n.text),
                  scope_n.nil?    ? nil      : scope_n.text,
                  optional_n.nil? ? false    : optional_n.text)
        end
      end

      # Substitutes given placeholder string for maven property.
      # Params:
      # +text+:: string with placeholder
      def resolve_prop(text)
        if text == '${project.version}'
          return @version
        elsif text.include? '$' and match = @@param_pattern.match(text)
          key, _ = match.captures
          return @props.fetch(key)
        end

        return text
      end
  end
end

# MVN::fetch_pom(DEP.new('com.sparkjava', 'spark-core', '2.7.2'))
# MVN::find_latest_version('javax.servlet', 'javax.servlet-api')
