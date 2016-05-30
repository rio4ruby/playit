require 'syslog'

class Slog
  include Syslog::Constants
  
  def initialize(name)
    Slog.open(name)
  end
  def self.open(name)
    openargs = [ Syslog::LOG_PID | Syslog::LOG_NDELAY, Syslog::LOG_LOCAL0 ]
    Syslog.__send__( (Syslog.opened? ? :reopen : :open),name, *openargs)
    Syslog.mask = Syslog::LOG_UPTO(Syslog::LOG_INFO)
    Slog
  end
  def self.auto
    self.open("") unless Syslog.opened?
    yield
  end
  def Slog.[](name)
    Slog.open(name)
  end

  [:emerg, :alert, :crit, :err, :warning, :notice, :info, :debug].each do |sym|
    prc = Proc.new { |*args|  
      auto { Syslog.__send__(sym,*args) }
    }
    define_singleton_method(sym,prc)
  end


end

