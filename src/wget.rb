module WGET
    # Runs wget in a new subprocess and
    # downloads file from url to path
    # Params:
    # +url+:: URL of file
    # +path+:: path for new file
    def self.run(path, url)
        IO.popen("wget -P #{path} #{url}") {|r| puts r.gets}
    end
end


# require_relative 'wget'
# WGET::run('./', 'http://central.maven.org/maven2/org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar')
