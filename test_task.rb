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


sleep 4
# Парсинг страницы с nokogiri
doc = Nokogiri::HTML.parse(browser.html)

sleep 4

# Берем информацию из ячеек таблицы
account_info = doc.css("tr.cp-item")
accounts = []
account_info.each do |row|
   td = row.css('td')
# Выводим данные в массив  
   accounts.push(
    account: td[1].text,
    currency: td[2].text.delete("Счёт "),
    balance: td[4].text.chop.delete(" ")
  )
end



# Переводим в формат json 
#tableJson = accounts.to_json

#p tableJson

first_row = browser.table(id: "contracts-list")[4].td(class: "span").click

sleep 4
doc = Nokogiri::HTML.parse(browser.html)

account_info = doc.css("#cards-list").css("tr.blockBody")
p account_info[0].css('td')[4].text

accounts.push(
   nature: account_info[0].css('td')[4].text account_info[1].css('td')[4].text
)
 
   sleep 4

    tableJson = accounts.to_json
    p tableJson

