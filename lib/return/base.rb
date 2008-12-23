module Riopro
  module KillBill
    module Return
      class Base
        
        attr_accessor :return_file_path
        attr_reader :header, :trailer, :transactions


        # Choses the correct return bank handler or throws an
        # error if bank is not supported
        def self.auto_initialize(return_file_path, auto_parse=true)
          raise "Return file not found" unless File.exist?(return_file_path)
          first_line = File.readlines(return_file_path)[0]
          if first_line[76..78] == "341"
            return Riopro::KillBill::Return::Itau.new(return_file_path, auto_parse)
          end
          raise "Can't found bank return parser for #{return_file_path}."
        end

        def initialize(return_file_path, auto_parse=true)
          raise "Return file not found" unless File.exist?(return_file_path)

          @return_file_path = return_file_path
          @parsed = false
          self.parse if auto_parse
        end
        
        # Returns true if the file has been succesfully parsed.
        def parsed?
          @parsed
        end
        
        protected
        
          # Returns the parsed content of the return_file. Also sets the +header+, 
          # +trailer+ and +transaction+ attributes from the parsed file.
          # 
          # Example:
          # 
          #  >> return.parse
          #  => { 
          #    :header => {...},
          #    :trailer => {...},
          #    :transactions => [
          #      {...},
          #      {...},
          #      {...}
          #    ]
          #  }
          # 
          def parse
            return_hash = {}
            return_file = File.readlines(self.return_file_path)
            
            # removes empty last line
            return_file.pop if return_file.last == "\n"
            
            return_hash[:header] = parse_header(return_file.first)
            return_file.delete_at(0)
            
            return_hash[:trailer] = parse_trailer(return_file.last)
            return_file.delete_at(return_file.size - 1)
            
            return_hash[:transactions] = []
            return_file.each do |transaction_line|
              return_hash[:transactions] << parse_transaction(transaction_line)
            end
            
            @header = return_hash[:header]
            @trailer = return_hash[:trailer]
            @transactions = return_hash[:transactions]
            
            @parsed = true
            
            return_hash
          end
        
        private
        
          # Parses the header line and returns a hash.
          # 
          # Overwrite this method on the child class!
          def parse_header(string)
            raise "Abstract method called - should overwrite this method on a child class"
          end
          
          # Parses the trailer line and returns a hash.
          # 
          # Overwrite this method on the child class!
          def parse_trailer(string)
            raise "Abstract method called - should overwrite this method on a child class"
          end
          
          # Parses a transaction line and returns a hash.
          # 
          # Overwrite this method on the child class!
          def parse_transaction(string)
            raise "Abstract method called - should overwrite this method on a child class"
          end
        
          # Receives a string with ddMMyy format and returns a date
          def convert_date(value)
            return nil unless value.length == 6
            ano = 0
            if value[4..5].to_i > 80
              ano = value[4..5].to_i + 1900
            else
              ano = value[4..5].to_i + 2000
            end
            Date.new(ano, value[2..3].to_i, value[0..1].to_i)
          end
      end
    end
  end
end