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



# Кликаем на тумблер для вывода всех счетов
browser.div(class: ["point", "text-center"]).click

sleep 2 
# Кликаем на первый сч
browser.table(id: "contracts-list")[3].td(class: "span").click

sleep 4
doc = Nokogiri::HTML.parse(browser.html)


# Берем информацию из ячеек таблицы
account_info = doc.css("tr.trHeader div.caption-hint")
table_info = doc.css("table.tbl-inform tr")



#account_info.each do |row|
#   td = row.css('td')

account_currency = doc.css("div#lnkContractTitle")  
cards_info = doc.css("#cards-list").css("tr.blockBody") 

accounts = []
#account_balance = doc.css("td.tdFieldVal")
# Выводим данные в массив  
   accounts.push(
    account: account_info[0].text,
    currency: account_currency.text.delete("Счёт "),
    balance: table_info[5].css('td')[2].text.chop.delete(" "),
    nature: "#{cards_info[0].css('td')[4].text}, #{cards_info[1].css('td')[4].text}"    
  )

# Выводилась ошибка, это её устранило  
Selenium::WebDriver.logger.level = :error
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

#       ...


sleep 2
# Полученные данные форматиреум в json и выводим
tableJson = accounts.to_json
p tableJson

