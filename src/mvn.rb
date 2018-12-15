require 'bundler/setup'
require 'nokogiri'
require 'faraday'

module MVN
  @@srch_conn = Faraday.new(:url => 'https://search.maven.org')
  @@remote_content = '/remotecontent?filepath=%s'

  # Fetches pom.xml from maven repository for given dependency
  # Returns pom object for given dependency
  # Params:
  # +dep+:: dependency declaration string
  def self.fetch_pom(dep)
    res = @@srch_conn.get @@remote_content % dep
    return POM.new res.body
  end

  class POM
    def initialize(pom_xml)
      puts 'init ' + pom_xml
      # Nokogiri::XML(res.body) {|config| config.noblanks}
    end
  end
end

# MVN::fetch_pom('com/sparkjava/spark-core/2.7.2/spark-core-2.7.2.pom')
