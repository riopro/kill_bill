# encoding: utf-8
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "rubygems"
require "date"
require "active_support"
require "kill_bill"

@boleto = Riopro::KillBill::Bank::Bradesco.new(
  :our_number => "606011457",
  :agency => "3369",
  :account => "0061605",
  :value => 123.45,
  :due_on => Date.today,
  :transferor => "Riopro Informática LTDA",
  :quantity => 1,
  :document_number => "304034",
  :cpf_or_cnpj => "00.000.000/0000-00",
  :drawee => { :name => "Otávio Sampaio", :address1 => "Rua Tal, 28", :address2 => "22222-222 - Rio de Janeiro" },
  :instructions => ["Pagável em qualquer agência até o vencimento.", "Após, favor solicitar outro."],
  :descriptions => ["Uma sardinha"]
)
@boleto.to_pdf_file("boleto_bradesco.pdf")
