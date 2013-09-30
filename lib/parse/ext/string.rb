unless String.methods.include? :camelize
  class String
    def camelize uppercase_first_letter=true
      ret = self.gsub(/_(\w)/) do $1.upcase end
      unless uppercase_first_letter == :lower
        ret = ret.capitalize
      end
      ret
    end
  end
end
