module DEP
  # Creates new dependency object
  def self.new(groupId, artifactId, version=nil, scope=nil, optional=false)
    return Dependency.new(groupId, artifactId, version, scope, optional)
  end

  class Dependency
    attr_reader :groupId, :artifactId, :version, :scope, :optional

    def initialize(groupId, artifactId, version, scope, optional)
      @groupId = groupId
      @artifactId = artifactId
      @version = version
      @scope = scope
      @optional = optional
    end

    # Returns dependency as a maven repository filepath string
    def filepath
      groupId = @groupId.gsub('.', '/')
      artifactId = @artifactId.gsub('.', '/')
      return "#{groupId}/#{artifactId}/#{@version}/#{artifactId}-#{@version}.pom"
    end

    def eql?(other)
      @groupId == other.groupId and
      @artifactId == other.artifactId and
      @version == other.version and
      @scope == other.scope and
      @optional == other.optional
    end

    alias :== :eql?

    def hash
      @groupId.hash + @artifactId.hash +
      @version.hash + @scope.hash + @optional.hash
    end

    def to_s
      return "#{@groupId}:#{@artifactId}@#{@version}"
    end
  end
end
