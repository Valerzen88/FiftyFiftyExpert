# FiftyFiftyExpert
MQL Expert

DE:
Handelt den überver- und überkauften Markt wenn Take Profit oder dynamischer Stop Loss erreicht wird. Bei Öffnen der Position werden zwei Pending Orders geöffnet: der erste (Größe der offenen Position * 0,625) bei 350 Punkten von einer offenen Position mit TakeProfit von 350 Punkten und den zweiten (Größe der offenen Position * 0,5) mit 750 Punkten Abstand von der geöffneten Position mit TakeProfit von 750 Punkten. Um die laufende Gewinne zu sichern, wurde der gleitende StopLoss eingeführt. Sollten die Pending Orders bis zum Schließen der vom Signal eröffneten Position sich nicht aktiviert haben, so werden diese auch geschlossen.

Neben der Fixen-Lot-Funktionalität wurde der dynamische Lotgrößenberechnung implementiert. Diese wird anhand des zur Verfügung stehenden freien Margins und des Kontohebels berechnet. 

Dieser Handelsroboter benutzt einen eigenen Indikator.

Die Einstellungen sind für das Handeln auf EURUSD, NZDUSD und GBPUSD optimiert. 

Zeiteinheiten: M30 bis H4

Die unten 
stehende Tabelle zeigt die besten Timeframes mit dem maximalen empfohlenen Risiko:

Symbol	Timeframe	Risk in %
EURUSD	M30 oder H1	50-90
NZDUSD	H4	40-50
AUDUSD	H1	50-70
Bitte seien Sie vorsichtig bei der Wahl des Risikowertes und testen Sie diese Werte für Ihren Broker!!! Die Ergebnisse können anders sein, wegen dem Spread oder anderen Spezifikationen Ihres Brokers!

Parameter:

LotSize=0.01 -> Größe der Position
LotAutoSize=true -> Dynamische Berechnung der Positionsgröße erlauben
RiskPercent=50 -> Risiko für die Positionsgröße. Wird anhand des freien Margins und des Hebels berechnet.
TrailingStep=50 -> Trailing Stop-Wert
DistanceStep=50 -> SL-Wert
MagicNumber=3537 -> Setzen Sie pro Handelsfenster diesen Wert neu

EN:
This EA trades on oversold or overbought market till TakeProfit or dynamic StopLoss will be reached. Next to the open position two pending orders will be opened: the first one (a size of the open position *0,625) at 350 points from an opened position with TakeProfit  of 350 points and the second one (a size of the open position *0,5) with 750 points distance of the open Position with TakeProfit from 750 Points.
To secure the current profit the gliding StopLoss was implemented.  If the pending orders didn’t activate till the closing of the opened position from the signal, they will be also closed.
 
In addition to fix-lot-functionality a dynamic size calculation of a lot was implemented. This will be calculated by means of free margin and by account leverage.
 
This trading robot uses its own integrated indicator.
 
The settings are optimized for handling on EURUSD, NZDUSD  and GBPUSD.
 
Time units are: M30 to H4

The table below shows the best timeframes with the maximum recommended risk:

Symbol	Timeframe	Risk in %
EURUSD	M30 oder H1	50-90
NZDUSD	H4	40-50
AUDUSD	H1	50-70

Please be prudent in choose of risk value and test this values for your broker!!! The results can be different, because of spread or other specification of your broker!

 
Parameters:
Lotsize= 0,01 -> size of the position
LotAutoSize -> to allow a dynamic calculation of the position size
Riskpercent=50 -> risk for the position size.It is calculated by means of the free margins and the leverage
TrailingStep=50 -> Trailing Stop value
DistanceStep=50 -> dynamic StopLoss value
MagicNumber=3537 -> set this value per trading window.

RU:
Робот торгует на перекупленном или перепроданном рынке используя собственный индикатор. При сигнале открывает позицию и два пендинг ордера: первый (размер открытой позиции*0,625) на 350 пунктов от открытой позиции с TakeProfit в 350 пунктов и второй (размер открытой позиции*0,5)  на растоянии 750 пунктов от открытой позиции с TakeProfit на уровне открытой позиции. Для сохранения прибыли в программе существует функция скользящего StopLoss. Если отложенные ордера не были использованы, они будут закрыты с закрытием основной позиции.

В дополнение к фиксированому размеру позиции, в программе можно использовать динамический размер позиции. Размер рассчитывается на основе имеющейся свободной маржи и рычага счета.

Прекрасно работает на EURUSD, NZDUSD и GBPUSD на таймфреймах от 30Мин до 4H

Пожалуйста, будьте благоразумны в выборе процента риска и проверьте эти значения для своего брокера!!! Результаты могут быть разными, из-за сперда или другой спецификации вашего брокера!


Параметры:

LotSize = 0.01 -> Размер позиции
LotAutoSize = true -> Разрешить динмамический выбор размера позиции
RiskPercent = 50 -> Риск для размера позиции. Рассчитывается с использованием свободного края и рычага
TrailingStep = 50 -> Значение TrailingStop
DistanceStep = 50 -> Начальное значение SL
MagicNumber = 3537 -> Установите это значение для каждого торгового окна

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
