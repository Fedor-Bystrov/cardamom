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
  # groupdId and artifactiId
  # Params:
  # +groupId+:: dependency groupId
  # +artifactId+:: dependency artifactId
  def self.get_latest_version(groupId, artifactId)
    res = @@srch_conn.get @@select_uri % [groupId, artifactId]
    res_json = JSON::parse(res.body).fetch('response')
    return res_json.fetch('docs')[0].fetch('latestVersion')
  end

  class POM
    def initialize(pom_xml)
      puts 'init ' + pom_xml
      # Nokogiri::XML(res.body) {|config| config.noblanks}
    end
  end
end

# MVN::fetch_pom('com/sparkjava/spark-core/2.7.2/spark-core-2.7.2.pom')
# MVN::get_latest_version('javax.servlet', 'javax.servlet-api')
