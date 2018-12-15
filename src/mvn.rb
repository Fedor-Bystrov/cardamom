require 'bundler/setup'
require 'nokogiri'
require 'faraday'
require 'json'

module MVN
  @@srch_conn = Faraday.new(:url => 'https://search.maven.org')
  @@remotecontent_uri = '/remotecontent?filepath=%s'
  @@select_uri = '/solrsearch/select?q=g:"%s"+AND+a:"%s"&rows=1&wt=json'

  # Fetches pom.xml from maven repository for given dependency
  # Returns pom object for given dependency
  # Params:
  # +dep+:: dependency declaration string
  def self.fetch_pom(dep)
    res = @@srch_conn.get @@remote_content % dep
    return POM.new res.body
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

    attr_reader :props, :deps

    def initialize(pom_xml)
      pom_doc = Nokogiri::XML(pom_xml) {|config| config.noblanks}
      @props = parse_props pom_doc
      @deps = parse_deps pom_doc
    end

    private
      # Parses maven pom root node and returns properties as ruby hash
      def parse_props(pom_doc)
        return pom_doc.css('properties').children.map {|c| [c.name, c.text]}.to_h
      end

      # Parses pom node and returns list of all dependencies
      # in "groupdId:artifactId@version" format
      # Params:
      # +pom_doc+:: mvn pom root node
      def parse_deps(pom_doc)
        return pom_doc.css('dependencies//dependency').map do |dep|
          groupId = dep.at('groupId').text
          artifactId = dep.at('artifactId').text
          version = resolve_property dep.at('version').text
          # TODO парсить текст scope или класть nil
          scope = dep.at('scope')
          # TODO парсить текст optional или класть false
          optional = dep.at('optional')

          Dependency.new(groupId, artifactId, version, scope, optional)
        end
      end

      # Substitutes given placeholder string for maven property.
      # Params:
      # +text+:: string with placeholder
      # +props+:: hash with properties from pom
      def resolve_property(text)
        if text.include? '$' and match = @@param_pattern.match(text)
          key, _ = match.captures
          return @props.fetch(key)
        end

        return text
      end
  end

  class Dependency
    attr_reader :groupdId, :artifactId, :version, :scope, :optional

    def initialize(groupId, artifactId, version, scope, optional)
      @groupId = groupId
      @artifactId = artifactId
      @version = version
      @scope = scope
      @optional = optional
    end
  end
end

# MVN::fetch_pom('com/sparkjava/spark-core/2.7.2/spark-core-2.7.2.pom')
# MVN::find_latest_version('javax.servlet', 'javax.servlet-api')
