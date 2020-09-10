require 'rspec'
require_relative 'neiva_bank.rb'


RSpec.describe NeivaBank do

  neivabank = NeivaBank.new

    it 'check number of accounts and show an example account' do
      accounts_html = Nokogiri::HTML.parse(File.read('html/accounts.html'))
      accounts = neivabank.parse_account(accounts_html, [])
    
      #expect(accounts.count).to eq(5)
      expect(accounts.first).to eq(        
       account: "40817810200000055320",
       currency: "RUB",
       balance: 1000000.0,
       nature: "account",
       transactions: []          
      )
    end  

    it 'check transactions' do
      transactions_html = Nokogiri::HTML.parse(File.read('html/transactions.html'))
      transactions = neivabank.parse_transactions(transactions_html, "40817810200000055320")
    
      #expect(accounts.count).to eq(3)
      expect(transactions.first).to eq(        
        account_name: "40817810200000055320", 
        amount: 50.0,
        currency: "RUB", 
        date: "2020-09-09", 
        description: "Оплата услуг МегаФон Урал, Номер телефона: 79111111111, 09.09.2020 11:59:59, Сумма 50.00 RUB, Банк-он-Лайн"          
      )
    end  

end