# Подключил все, что необходимо
require 'rubygems'
require 'watir'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'openssl'                                                      

# Выходила ошибка с SSL. Это для того, чтоб она больше не появлялась
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE                                                 

bank_url = "https://demo.bank-on-line.ru/"


# Открываем окно и выходим на нужную страницу
browser = Watir::Browser.new  
browser.goto bank_url

# Клик на кнопке "Войти"
browser.div(class: ["button", "radius", "button-demo"]).click  

sleep 4

 # Клик на вкладку "Счета"
browser.a(id: "lnkContracts").click                            

# Парсим страницу со счетами
sleep 2 
doc = Nokogiri::HTML.parse(browser.html)

# Проходим по каждому счету, начиная с 3-го "tr"
account_info = doc.css("tr.cp-item")
accounts = []
i = 2                                                                 #
account_info.each do |row|
    # Кликаем на счет и со страницы счета берем нужную инфу
    browser.table(id: "contracts-list")[i].td(class: "span").click
    sleep 4
    doc = Nokogiri::HTML.parse(browser.html)
    account_info = doc.css("tr.trHeader div.caption-hint")
    table_info = doc.css("table.tbl-inform tr")
    account_currency = doc.css("div#lnkContractTitle")  
    cards_info = doc.css("#cards-list").css("tr.blockBody") 


    
    sleep 2
    # Поскольку бургер с доп.инфо уже открыт по умолчанию, идём к списку транзакций
    browser.ul(id: "drop-action").li(class: "operhist").click

    doc = Nokogiri::HTML.parse(browser.html)
    sleep 2

    # Берем транзакции за 2 месяца
    browser.div("inputid" => "DateFrom").click
    sleep 1
    # На месяц назад
    browser.span(text: "Пред").click

    sleep 1

    # Исходя из сегодняшней даты ищем нужную
    time = Time.new
    day_today =  time.day.to_s

    browser.a(text: "#{day_today}").click

    # Кликаем на поиск
    browser.span(id: "getTranz").click
    sleep 4
    #       ...
    doc = Nokogiri::HTML.parse(browser.html)

    # Создаем массив с транзакциями
    transaction_info = doc.css("tr.cp-transaction")
    transactions = []
    transaction_info.each do |transaction_row|
      transaction_data              = transaction_row.css('td')
      transaction_description       = transaction_data[6].text
      transaction_description_array = transaction_description.split(',')
      transaction_currency          = ''
      # Выводим валюту
      transaction_description_array.each do |currency|
          if currency.include? "Сумма"
            transaction_currency = currency[-3..-1]             
          end
      end
      # Выводим описание транзакции до слова "Статус"
      sub_transaction_description = transaction_description.split('Статус')[0]

      transactions.push(  
        date: transaction_data[1].text,
        description: sub_transaction_description,
        amount: transaction_data[4].text.chop,
        currency: transaction_currency,
        account_name: account_info[0].text
      )
    end



    td = row.css('td')
    
    
    # Выводим данные в массив  
     accounts.push(
      account: td[1].text,
      currency: td[2].text.delete("Счёт "),
      balance: td[4].text.chop.delete(" "),
      nature: "#{cards_info[0].css('td')[4].text}",
      transactions: transactions  
    )   
    i = i + 1
    Selenium::WebDriver.logger.level = :error
    browser.a(id: "lnkContracts").click  
    
    
    sleep 4
end

sleep 2
# Полученные данные форматиреум в json и выводим
tableJson = accounts.to_json
p tableJson

sleep 2