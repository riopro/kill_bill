#
# Include new method to ruby base classes
#

class Fixnum; include Riopro::KillBill::Extensions::Currency::Number; end
class Bignum; include Riopro::KillBill::Extensions::Currency::Number; end
class Float; include Riopro::KillBill::Extensions::Currency::Number; end
class String; include Riopro::KillBill::Extensions::Currency::String; end

# Inclui os Modulos nas Classes Correspondentes
class String
  include Riopro::KillBill::Extensions::Format
  include Riopro::KillBill::Extensions::Validation
end

class Integer
  include Riopro::KillBill::Extensions::Format
end

class Float
  def clear_currency_value
    return self unless self.kind_of?(Float)
    valor_inicial = self.to_s
    (valor_inicial + ("0" * (2 - valor_inicial.split(/\./).last.size ))).numbers_only
  end
end

class Date
  # Calculates the number of days since 07-10-1997 for
  # a date. It's a BACEN pattern for billing dates
  def due_day_factor
    data_base = Date.parse "1997-10-07"
    return (self - data_base).to_i
  end

  def to_s_br
    self.strftime('%d/%m/%Y')
  end
end

class TrueClass
  def to_s_br
    "Sim"
  end
end

class FalseClass
  def to_s_br
    "Não"
  end
end
