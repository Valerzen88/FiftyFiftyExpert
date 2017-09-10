# FiftyFiftyExpert
MQL Expert

AreaFiftyOne Expert

DE:
Handelt den Markt bei der Trendwende bis zu einem dynamisch nachziehenden Stop Loss. Dieser Handelsroboter implementiert 2 unterschiedliche Indikatoren, welche sich auf unterschiedliche Weise kombinieren lassen. Dabei ist das Money Management so integriert, dass es einen fixen sowie einen variablen Lot erlaubt.

Zusätzlich gibt es die Möglichkeit manuelle Positionen durch den Handelsroboter übernehmen lassen.

Die Einstellungen sind für das Handeln auf EURUSD, NZDUSD, GBPJPY, USDJPY, USDCHF, AUDCAD und GBPUSD optimiert.

Zeiteinheiten: M15 bis H4

Bitte seien Sie vorsichtig bei der Wahl des Risikowertes und testen Sie diese Werte für Ihren Broker!!! Die Ergebnisse können wegen dem Spread oder anderen Spezifikationen Ihres Brokers abweichen!
Hinweise:

Je größer das Timeframe, desto sicherer, dass die Position größeren und sicheren Gewinn bring. Die kleineren Timeframes (M5-M15) sollten eher im Seitwärtsmarkt verwendet werden.
Je kleiner der Spread, desto größer der Gewinn.
Eine Verwendung von einem virtuellen Server ist empfehlenswert.


Parameter
LotSize=0.01 -> Größe der Position
LotAutoSize=false -> Dynamische Berechnung der Positionsgröße erlauben
RiskPercent=25 -> Risiko für die Positionsgröße. Wird anhand des freien Margins und des Hebels berechnet
MoneyRiskInPercent=0 -> Zur Sicherheit kann hier der empfohlene Wert von 32 eingetragen werden
UseTrendBasedIndicator=true -> den Trendindikator für Signale verwenden.
UseRSIBasedIndicator=true -> den RSI-basierten Indikator für Signale verwenden.
UseSMAOnTrendIndicator=true -> Gleitenden Mittelwert für die Signalbildung auf den Trendindikator verwenden
UseOneOrTwoSMAOnTrendIndicator=2 -> Einen oder zwei gleitenden Mittelwerte verwenden
TrailingStep=15 -> Trailing Stop-Wert
DistanceStep=15 -> SL-Wert
MagicNumber=3537 -> Setzen Sie pro Handelsfenster eines Währungspaares diesen Wert neu
TakeProfit=750 -> Take Profit für eventuelle Gaps
StopLoss=0 -> Standardwert ist 10000 Punkte
StartHour=8 -> Ab diesem Zeitpunkt startet der Handel
EndHour=22 -> Ab diesem Zeitpunkt werden keine neue Positionen an diesem Tag mehr eröffnet
HandleUserPositions=false -> Übernehmen der manuell eröffneten Positionen

Optimale Einstellungen für Ihr Konto können über PN angefragt werden.

EN:
This EA trades based on the changes of the trend in the market, using custom indicators. There are 2 indicators: an RSI-based and a trend-based indicator. By default, the trend indicator is activated. Simultaneous use of both indicators is also possible.

In addition to fix-lot-functionality, a dynamic size calculation of a lot was implemented. It will be calculated by means of free margin and by account leverage.

We added a new function for taking over of manually opened positions.

The settings are optimized for trading on EURUSD, USDCHF, NZDUSD, GBPJPY, AUDCAD, USDJPY and GBPUSD.

Timeframes are: M15 to H4

Please be prudent in choose of risk value and test this values for your broker!!! The results can be different, because of spread or other specification of your broker!
Hints:

The larger the timeframe, the safer that the position will bring greater and safer profit. The smaller timeframes (M5-M15) should rather be used in the sideways market.
The smaller the spread, the greater the profit.
It is recommended to use a virtual server.


Parameters
Lotsize= 0,01 -> size of the position
LotAutoSize=false -> allow a dynamic calculation of the position size
LotRiskPercent=25 -> risk for the position size. It is calculated by means of the free margins and the leverage
MoneyRiskInPercent=0 -> Value in percent, reaching which the program closes all of program opened trades
UseRSIBasedIndicator = false -> Use RSI-based indicator
UseTrendIndicator = true -> Use trend-based indicator
UseSMAOnTrendIndicator=true -> Using moving average for signal creation
UseOneOrTwoSMAOnTrendIndicator=2 -> Using one or two moving average lines for signal creation
TrailingStep = 50 -> TrailingStop value (the smaller the timeframe, the smaller the value!)
DistanceStep = 50 -> SL value (the smaller the timeframe, the smaller the value!)
MagicNumber=3537 -> set this value per trading window
TakeProfit=750 -> Take profit for possible gap's
StopLoss=0 -> Standard value is 10000 points
HandleUserPositions=false -> handle manually opened positions
StartHour=8 -> Start time for trading
EndHour=22 -> End time for trading

Optimal settings for your account can be requested via PN.

RU:
Робот торгует на изменении тренда на рынке, используя собственные индикаторы. В программе используются два индикатора: первый на основе RSI и индикатор на основе тренда. По умолчанию активирован индикатор тренда. Одновременное использование двух индикаторов также возможно.

В дополнение к фиксированному размеру позиции в программе можно использовать динамический размер позиции. Размер рассчитывается на основе имеющейся свободной маржи и размере плеча счета.

Так же добавлена фунция перенятия вручную открытых позиций в платной версии.

Работает на EURUSD, NZDUSD, GBPJPY, USDJPY, AUDCAD, USDCHF и GBPUSD на таймфреймах от M15 до H4.

Пожалуйста, будьте благоразумны при выборе процента риска и проверьте эти значения для своего брокера!!! Результаты могут быть разными из-за сперда или другой спецификации вашего брокера!


Параметры
LotSize = 0.01 -> Размер позиции
LotAutoSize = false-> Разрешить динамический выбор размера позиции
LotRiskPercent = 25 -> Риск для размера позиции. Рассчитывается на основе свободной маржи и плеча
MoneyRiskInPercent = 0 -> Значение убытка в процентах, при котором программа закрывает все открытые сделки
UseRSIBasedIndicator=false -> Использование индикатора на основе RSI
UseTrendIndicator=true -> Использование индикатора на основе тренда
UseSMAOnTrendIndicator=true ->Использование скользящих средних для создания сигнала
UseOneOrTwoSMAOnTrendIndicator=2 -> Использование одной или двух из скользящих средних
TrailingStep = 50 -> Значение TrailingStop (используйте небольшие значения на низких таймфреймах)
DistanceStep = 50 -> Начальное значение SL (используйте небольшие значения на низких таймфреймах)
MagicNumber = 3537 -> Магическое число, установите это значение для каждого торгового окна
TakeProfit=750 -> Take profit для возможных гэпов
StopLoss=0 -> Стандартное значение 10000 пунктов
HandleUserPositions=false -> Перенятие вручную открытых позиций
StartHour=8 -> Стартовое время для открытия позиций
EndHour=22 -> Конечное время для открытия позиций

Оптимальные настройки для вашей учетной записи могут быть запрошены через PM.

Area51 Little Helper

DE:
Dieser kleine Werkzeug übernimmt manuell eröffnete Positionen und behandelt diese nach den vorgegebenen Einstellungen mit dem dynamischen Stop Loss und Money Management, welches vorhersagt, welche Positionsgröße zunächst verwendet werden soll. Das Programm setzt den Stop Loss dynamisch nach, sobald die Position in Plus kommt. Es werden eventuelle Kommissionen und Swaps berücksichtigt. Pro Symbol sollte es nur in einem Chart-Fenster installiert werden.

Einstellungen:

LotRiskPercent=25 --> Prozentuale Angabe für die Positionsgröße. Wird berechnet anhand der Equity, Hebels und freien Margins. Der Wert darf zwischen 0.1 bis 1000 sein.
MoneyRiskInPercent=0 --> Der Wert darf von 0 bis 100 sein. Wie viel Kapital darf riskiert werden? Wenn der Wert erreicht wird, alle Positionen des Symbols werden geschlossen. Seien Sie vorsichtig damit.
TrailingStep=15 -->  Trailing Step für jeweilige Position.
DistanceStep=15 --> Abstand zur Position + TrailingStep-Größe ab welcher der nächste Trailing Step gesetzt wird.
TakeProfit=750 --> Take Profit für jede übernommene Position.
StopLoss=0 --> Stop Loss für jede übernommene Position.


Beispiel:

Es wird eine Long-Position bei EURUSD auf dem Niveau von 1.20000 eröffnet. Das Programm setzt ein Take Profit bei 1.20750. Bei einem Spread von 10 Points, einem TrailingStep, sowie den DistanceStep von 15 wird der erste StopLoss in Plus bei 1.20040 gesetzt. Wenn negative Swaps und Kommissionen hinzukommen, so werden diese in Points umgerechnet. Somit wird jede Position im Plus geschlossen.

EN:
This small tool takes over the manually opened positions and treats them according to the predefined settings with the dynamic stop loss and money management, which predicts which position size should be used for the trade. The program dynamically tracks the stop loss as soon as the position comes into the plus. Possible commissions and swaps are taken into calculation. Per symbol it should only be installed on one chart window.

Settings:

LotRiskPercent = 25 -> Percentage of the item size. Calculated on the basis of equity, leverage and free margins. The value can be between 0.1 and 1000.
MoneyRiskInPercent = 0 -> The value can be from 0 to 100. How much capital can be risked? Once the value is reached, all positions of the symbol will be closed. Please, be careful with it.
TrailingStep = 15 -> Trailing step for each position.
DistanceStep = 15 -> Distance to position + TrailingStep size from which the next trailing step will be set.
TakeProfit = 750 -> TakeProfit for each taken position.
StopLoss = 0 -> Stop Loss for each taken position.

Example:

A long position with EURUSD is opened at the level of 1.20000. The program sets a Take Profit at 1.20750. With a spread of 10 points, a TrailingStep as well as the DistanceStep of 15, the first StopLoss in Plus will be set to 1,20040. If negative swaps and commissions are added, they will be converted into points. So each position will be closed always in plus.

RU:
Этот небольшой инструмент перенимает открытые вручную позиции и обрабатывает их в соответствии с предопределенными настройками с динамическим стоп-лосс и Money Management, который предсказывает, какой размер позиции следует использовать при открытие новой позиции. Данная программа динамически отслеживает стоп-лосс, как только позиция попадает в плюс. Принимаются во внимание возможные комиссии и свопы. На каждый символ программа должа быть установлена только на одном чарте.

Настройки:

LotRiskPercent = 25 -> Процент размера позиции. Рассчитывается на основе капитала, кредитного плеча и свободной маржи. Значение может быть от 0,1 до 1000.
MoneyRiskInPercent = 0 -> Значение может быть от 0 до 100. Каким количеством капитала можно рисковать? Когда значение достигнуто, все позиции символа будут закрыты. Будьте осторожны с этим.
TrailingStep = 15 -> Шаг трейлинга для каждой позиции.
DistanceStep = 15 -> Расстояние до позиции + размер TrailingStep, от которого будет поставлен следующий шаг трейлинга.
TakeProfit = 750 -> Take profit для каждой выбранной позиции.
StopLoss = 0 -> стоп-лосс для каждой выбранной позиции.

Пример:

Позиция на повышение на EURUSD открывается на уровне 1.20000. Программа устанавливает Take Profit на уровне 1.20750. Со спредом в 10 пунктов, TrailingStep, а также DistanceStep 15, первый стоп-лосс с плюсом будет установлен на уровне 1.20040. Если добавляются отрицательные свопы и комиссии, они будут преобразоватьсяв пункты, то есть каждая позиция будет в плюсе.
