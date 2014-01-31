module ::ArJdbc
  extension :Teradata do |name|
    if name =~ /teradata/i
      require 'arjdbc/teradata'
      true
    end
  end
end
