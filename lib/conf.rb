class ConfigurationNotFoundError < StandardError  
end

class Conf
  def method_missing(name)
    begin
      option = Option.find_by_option_name(name.to_s)
      return option.option_value
    rescue NoMethodError => e
      raise ConfigurationNotFoundError
    end
  end
end