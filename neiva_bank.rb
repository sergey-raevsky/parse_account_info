require 'rubygems'
require 'watir'
require 'nokogiri'
require 'json'

class NeivaBank

  attr_accessor :browser, :accounts
  
  def initialize
    @browser = Watir::Browser.new :chrome
    @account_id
    @transactions
  end
  
  
  def execute
     connect
     fetch_accounts
  end

  
  def connect  
    browser.goto("https://demo.bank-on-line.ru/")
    browser.window.maximize
    sleep 2    
    browser.div(class: ["button", "radius", "button-demo"]).click
    sleep 4
    browser.a(id: "lnkContracts").click
    sleep 2 
  end 


  def fetch_accounts
    sleep 2 
    doc = Nokogiri::HTML.parse(browser.table(class: "cp-page-list").html)
    account_info = doc.css("tr.cp-item")
    accounts = []
    i = 2                                                                 
    account_info.each do |row|
      browser.table(id: "contracts-list")[i].td(class: "span").click
      sleep 4
      doc = Nokogiri::HTML.parse(browser.table(class: "tbl-inform").html)
      account_id = doc.css("tr.trHeader div.caption-hint")    
      sleep 2 
      transactions = fetch_transactions(account_id)        
      accounts.push(parse_account(row, transactions))
      i = i + 1      
      browser.a(id: "lnkContracts").click      
      sleep 4
    end
    sleep 2
      File.open("accounts_data.txt","w") do |data|
        data.write(JSON.pretty_generate({accounts: accounts}))
      end
  end

  def parse_account(account_info, transactions)
    td = account_info.css('td')   
    account = [
      account: td[1].text,
      currency: td[2].text.delete("Счёт "),
      balance: td[4].text.delete("₽").delete(" ").to_f,
      nature: "account",
      transactions: transactions 
    ]
    account
  end  


  def fetch_transactions(account_id)
    browser.ul(id: "drop-action").li(class: "operhist").click    
    sleep 2    
    browser.div("inputid" => "DateFrom").click
    sleep 1
    browser.span(text: "Пред").click
    sleep 1    
    time = Time.new
    day_today =  time.day.to_s
    browser.a(text: "#{day_today}").click    
    browser.span(id: "getTranz").click
    sleep 4    
    list_transactions = Nokogiri::HTML.parse(browser.table(class: "cp-last-transactions").html)   
    parse_transactions(list_transactions, account_id[0].text)
  end


  def parse_transactions(list_transactions, account_name)
    transaction_info = list_transactions.css("tr.cp-transaction")
    transactions = []
    transaction_info.each do |transaction_row|
      transaction_data              = transaction_row.css('td')
      transaction_description       = transaction_data[6].text
      transaction_description_array = transaction_description.split(',')
      transaction_currency          = ''      
      transaction_description_array.each do |currency|
        if currency.include? "Сумма"
          transaction_currency = currency[-3..-1]             
        end
      end
      transaction_date = transaction_data[1].text[0, 10].split('.').reverse      
      sub_transaction_description = transaction_description.split('Статус')[0]    
      transactions.push(  
        date: "#{transaction_date[0]}-#{transaction_date[1]}-#{transaction_date[2]}",
        description: sub_transaction_description,
        amount: transaction_data[4].text.delete("₽").delete(" ").to_f,
        currency: transaction_currency,
        account_name: account_name
        )
     end
     transactions
  end

end
