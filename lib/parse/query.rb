module Parse
  class Query
    attr_reader :keys
    attr_accessor :parse_class_name, :parse_client

    def initialize parse_class_name=nil, parse_client=nil
      @parse_class_name = parse_class_name.to_s
      @parse_client = parse_client || Parse::Client.default
      @limit = nil
      @skip = nil
      @count = false
      @where = [] # array of Conditions
      @order = []
      @include = []
      @keys = []
    end

    def run &block
      block = proc do |body| 
        # TODO: should handle error
        results = body['results']
        results.query_count = body['count'] if results
        results
      end unless block
      endpoint = %w(User).include?(@parse_class_name) \
        ? "#{@parse_class_name.lowercase}s" 
        : "classes/#{@parse_class_name}"
      @parse_client.call_api :get, "#{endpoint}?#{to_params}", nil, &block
    end
    alias invoke run

    def limit val=nil
      if val
        @limit = val
      else
        @limit
      end
      self
    end

    def skip val=nil
      if val
        @skip = val
      else
        @skip
      end
      self
    end

    def count val=nil
      if val
        @count = val
      else
        @count
      end
      self
    end

    def where hash=nil, &block
      return @where if hash.nil? && block.nil?

      if hash.is_a? Hash
        hash.each do |k, v|
          @where << %Q|"#{k}":#{v.inspect}|
        end
      else
        block = hash if hash.is_a?(Proc) && block.nil?
        instance_eval &block if block
      end
      self
    end

    def order *vals
      return @order if vals.empty?
      @order += vals
      self
    end
    alias order_asc order

    def order_desc *vals
      order *(vals.map do |val|
        val[0] == '-' ? val[1..-1] : "-#{val}"
      end)
    end

    def keys *vals
      return @keys if vals.empty?
      @keys += vals
      self
    end

    def include *vals
      return @include if vals.empty?
      @include += vals
    end

    def to_params
      params = []

      where = @where.join ','
      order = @order.join ','
      keys = @keys.join ','
      include = @include.join ','
      params.push "where=#{URI.encode "{#{where}}"}" unless where.empty?
      params.push "order=#{URI.encode order}" unless order.empty?
      params.push "keys=#{URI.encode keys}" unless keys.empty?
      params.push "include=#{URI.encode include}" unless include.empty?
      params.push "skip=#{URI.encode @skip.to_s}" if @skip
      params.push "limit=#{URI.encode @limit.to_s}" if @limit
      params.push "count=1" if @count

      params.join '&'
    end

    def inspect
      "#{@parse_class_name}, #{to_params}"
    end

    private

    def column name
      Condition.new(self, name).tap do |condition|
        @where.push condition
      end
    end
    alias _ column

    def subquery_for parse_class_name
      Subquery.new parse_class_name
    end

    def or_condition *conds
      conds.each do |cond|
        @where.delete cond
      end
      OrCondition.new(conds).tap do |condition|
        @where.push condition
      end
    end
    alias _or_ or_condition

    def related_to column_name, pointer
      RelatedToCondition.new(column_name, pointer).tap do |condition|
        @where.push condition
      end
    end

    class Subquery < Query
      attr_accessor :parent

      def initialize parse_class_name=nil
        super
        @key = nil
      end

      def key= val
        @key = val
        self
      end
      alias key key=

      def inspect
        # TODO should be refactored
        case @parent
        when :select, :dont_select
          %Q|{"query":{"className":#{parse_class_name.to_s.inspect},"where":{#{@where.join ','}}},"key":#{@key.inspect}}|
        when :in_query, :not_in_query
          %Q|{"where":{#{@where.join ','}},"className":#{parse_class_name.to_s.inspect}}|
        end
      end
    end

    class Condition
      def initialize query, column_name
        @query = query
        @column_name = column_name
        @conditions = []
      end

      # receive nop
      %w(eq contains).each do |op|
        eval %Q{
          def #{op} val
            @conditions.push val
            self
          end
        }
      end
      alias equal_to eq

      # receive single param
      %w(lt lte gt gte ne).each do |op|
        eval %Q{
          def #{op} val
            @conditions.push ['$#{op}', val]
            self
          end
        }
      end
      alias less_than lt
      alias less_that_or_equal_to lte
      alias greater_than gt
      alias greater_that_or_equal_to gte
      alias not_equal_to ne

      def between range
        if range.exclude_end?
          self.gt(range.begin).lt(range.end)
        else
          self.gte(range.begin).lte(range.end)
        end
      end

      def exists val=true
        @conditions.push ['$exists', val]
        self
      end

      # receive multi params
      %w(in nin all).each do |op|
        eval %Q{
          def #{op} *vals
            if vals.size == 1 && vals.first.is_a?(Array)
              vals = vals.first
            end
            @conditions.push ['$#{op}', vals]
            self
          end
        }
      end
      alias not_in nin

      # receive subquery
      %w(select dont_select in_query not_in_query).each do |op|
        eval %Q{
          def #{op} subquery
            subquery.parent = :#{op}
            @conditions.push ['$#{op.camelize :lower}', subquery]
            self
          end
        }
      end

      def or cond
        # quite dirty!!
        @query.where.delete self
        @query.where.delete cond
        or_cond = Condition.new @query, '$or'
        or_cond.eq [self, cond]
        @query.where.push or_cond
      end

      # conditions for GeoPoints

      def near_sphere geo_point
        @conditions.push ['$nearSphere', geo_point]
        self
      end

      def max_distance_in_miles miles
        @conditions.push ['$maxDistanceInMiles', miles]
        self
      end

      def max_distance_in_kilometers kilometers
        @conditions.push ['$maxDistanceInKilometers', kilometers]
        self
      end

      def max_distance_in_radians radians
        @conditions.push ['$maxDistanceInRadians', radians]
        self
      end

      def within southwest_geo_point, northeast_geo_point
        @conditions.push WithinCondition.new(southwest_geo_point, northeast_geo_point)
        self
      end

      def regex regex
        @conditions.push ['$regex', regex.source]
        self
      end

      # https://parse.com/questions/are-like-or-regex-queries-possible-via-the-rest-api
      def starts_with str
        regex %r|^\Q#{str}\E|
      end

      def to_s
        if @conditions.size == 1 && !@conditions[0].is_a?(Array)
          "#{@column_name.to_s.inspect}:#{condition_to_s @conditions[0]}"
        elsif @conditions.size == 1 && @conditions[0][0].to_s[0] != '$'
          # $or
          "#{@column_name.to_s.inspect}:#{condition_to_s @conditions[0]}"
        else
          "#{@column_name.to_s.inspect}:{#{@conditions.map{|c| condition_to_s c}.join ','}}"
        end
      end

      private

      def condition_value_to_s val
        case val
        when Parse::Object
          %Q|{"__type":"Pointer","className":"#{val.parse_class_name}","objectId":"#{val.parse_object_id}"}|
        when Parse::GeoPoint
          val.to_json
        when Parse::ParseDate
          val.to_json
        else
          val.inspect
          #val.to_json
        end
      end

      def condition_to_s condition
        case condition
        when Array
          if condition[0].to_s[0] == '$'
            "#{condition[0].inspect}:#{condition_value_to_s condition[1]}"
          else
            # $or
            "[#{condition.map{|c| "{#{condition_value_to_s c}}"}.join ','}]"
          end
        else
          condition_value_to_s condition
        end
      end
    end

    class OrCondition
      def initialize conds
        @conditions = conds
      end

      def to_s
        %Q|"$or":[#{@conditions.map {|c| "{#{c.to_s}}"}.join ','}]|
      end
    end

    class RelatedToCondition
      def initialize column_name, pointer
        @column_name = column_name
        @pointer = pointer
      end

      def to_s
        %Q|"$relatedTo":{"object":#{@pointer.to_json},"key":"#{@column_name}"}|
      end
    end

    class WithinCondition
      def initialize southwest_geo_point, northeast_geo_point
        @southwest_geo_point = southwest_geo_point
        @northeast_geo_point = northeast_geo_point 
      end

      def to_s
        %Q|{"$within":{"$box":[#{@southwest_geo_point.to_json},#{@northeast_geo_point.to_json}]}}|
      end
    end
  end

  def Query parse_class_name=nil
    Query.new parse_class_name
  end
end
