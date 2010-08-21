class ConfigurationNotFoundError < StandardError  
end

class Conf
  def method_missing(name)
    begin
      option = Option.find_by_option_name(name.to_s)
      if option.option_type=='integer'
        return option.option_value.to_i
      elsif option.option_type=='string' || option.option_type=='text'
        return option.option_value.to_s
      elsif option.option_type=='boolean'
        # false would be 'f'
        return option.option_value=='t'
      end
    rescue NoMethodError => e
      raise ConfigurationNotFoundError
    end
  end
end