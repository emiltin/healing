class String

  def camelcase
    gsub(/(^|_|-)(.)/) { $2.upcase }
  end

  def underscore
    gsub(/\B[A-Z]+/, '_\&').downcase
  end

end





