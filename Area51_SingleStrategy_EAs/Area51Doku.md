Deutsch(neu):

Dieser Expert Advisor generiert Signale bei den Trendänderungen. Die Signalgenerierung kann mithilfe von verschiedenen Strategien stattfinden. 
Beim Zustandekommmen einer Position wird diese mit einem Take Profit und Stop Loss versehen. Sofern die Position in Plusbereich sich bewegt, wird
ein dynamisch nachziehender Stop Loss auf Basis der vordefinierten Werten (TrailingStep und DistanceStep) gesetzt und immer wieder nachgezogen, somit wird erreicht, dass die Postition immer im Plus geschlossen wird.

Features:

Das Money Management ist dabei so aufgeteilt, dass man eine statische Lot-Größe ausgewählt werden kann oder eine dynamisch kalkulierte Lot-Größe, welche anhand der zur Verfügung stehenden liquiden Mitteln, des Hebels und des freien Margins ausgerechnet wird.

In einem reinen Buy-Markt oder einem Sell-Markt kann man ausgewählen, in welche Richtung die Positionen bei Signalbildung eröffnet werden sollen.

Ein weiteres Feature des Expert Advisors ist die Fähigkeit die manuell eröffnente Positionen des Benutzers nach den Regeln des Handelsroboters zu übernehmen und diese zum erfolgreichen Abschluss zu bringen.

Der Handelsroter kann auf unterschiedlichen Handelsinstrumenten eingesetzt werden (Somit ist es unwichitg, wieviele Digits der Broker anbietet). Optimale Ergebnisse werden aber  auf EURUSD, NZDUSD, GBPJPY, USDJPY, USDCHF, AUDCAD und GBPUSD erzielt.

Durch die Zeitfunktion kann man die Arbeitszeit des Handelsroboters regeln. Meistens in der Nacht (GMT Zeit) werden falsche Signale vom Markt generiert, welche in der Regel zu den Drawdowns führen.

Durch die Möglichkeit die sog. MagicNumber sertzen zu können, lässt sich der Handelsroboter auf unterschiedlichen Timeframes eines Handelsinstrumenten einsetzen.

Möglichkeiten der Strategien:
 - Alle Strategien lassen sich gleichzeitig verwenden oder man wählt nur eine aus.
 - Strategien werden anhand der verschiedenen Indikatoren und deren Kombinationen realisiert.
 - Aktuell wird nur eine Position in jewelige Richtung eröffnet. Solange diese aktiv ist, werden neue Signale in diese Richtung ignoriert.
 - Eine Variante, wie man den Handelsroter aktiver nutzen kann, ist, wenn man z.B. auf verschiedenen Chartfenstern die Strategien einzeln nutzt.
 - Die andere Möglichkeit ist es, die ausgewählte Strategie auf einem Handelsinstrument, aber auf unterschiedlichen Timeframes  zu nutzen.
 - Es dürfen verschiedene Timeframes für die Nutzung des Handelsroboters ausgewählt werden. Optimale Timeframes sind aber von M15 bis H4.
 
 Parameter und Strategien:
 
	Trading="Base trading params";
		LotSize=0.01 -> Feste Größe der Position
		LotAutoSize=false -> Dynamische Berechnung der Positionsgröße erlauben. LotSize wird dabei ignoriert.
		LotRiskPercent=25 -> Risiko für die Positionsgröße. Wird anhand des freien Margins, frei zur Verfügung stehenden liquiden Mitteln und des Hebels berechnet.
		MoneyRiskInPercent=0 -> Zur Sicherheit kann hier der empfohlene Wert von z.B. 32 eingetragen werden. Beim Erreichen des prozentuallen Wertes werden alle Positionen für alle Chartfenster mit der gleichen MagicNumber sofort geschlossen. Bitte verwenden Sie diese Option mit Bedacht.
		MaxDynamicLotSize=0.0 -> Die maximal mögliche Lot-Größe bei eingeschalteter LotAutoSize-Funktion kann hier bestimmt werden. Wenn der eingegebene Wert größer als die maximal mögliche Größe des Lots des Handelsinstrumenten ist, so wird dann der maximal Wert für diesen Handelsinstrumenten verwendet.
	Positions="Handle positions params";
		TrailingStep=15 ->  Gibt an, in welchen Schritten der Trailing Step, abhängig von dem Eröffnungspreis der Position, gesetzt werden soll.
		DistanceStep=15 -> Gibt den Schritt, abhängig von dem aktuellen  Kurs, an,  ab welchen der Trailing Step, nachgezogen werden soll.
		TakeProfit=750 -> Take Profit für die Position an. Soll auch als Sicherheit bei Gaps immer gesetzt sein.
		StopLoss=0 -> Stop Loss Wert für die Positionen. Standardwert liegt bei 10000 Punkten.
	Indicators="Choose strategies";
	TrendIndicatorStrategy="-------------------";
		UseTrendIndicator=true -> Trend-basierter Indikator
		UseSMAOnTrendIndicator=true -> Gleitende Mittelwerte auf den Indikatorwerten benutzen.
		UseOneOrTwoSMAOnTrendIndicator=1 -> Gleitender Mittelwert mit kleineren Wert(1), Gleitender Mittelwert mit kleinen und großen Wert(2) oder nur den zweiten (3) mit großen Wert benutzen.
		UseSMAsCrossingOnTrendIndicatorData=false -> Kreuzung der beiden Gleitenden Mittelwerten 
	RSIBasedStrategy="-------------------";
		UseRSIBasedIndicator=false -> RSI-basierter Indikator.
	MACD_ADX_MA_Strategy="-------------------";
		UseSimpleTrendStrategy=false -> Strategie basierend auf MACD und einen Gleitenden Mittelwert. Zusätzliche Unterstützung leistet dabei der ADX Indikator.
	SimpleStochasticCrossingStrategy="-------------------";
		UseStochasticBasedIndicator=false -> Einfache Kreuzung des Stochastik Indikators auf überkauften oder überverkauften Markt. Empfehlenswert bei Timeframes ab H4.
	ADX_RSI_MA_Strategy="-------------------";
		Use5050Strategy=false ->  auf größeren RSI-Wert baisert: Wert größer 50 bedeutet ein Kaufsignal, sonst ein Verkaufssignal.
	StochastiCroosingRSIStrategy="-------------------";
		UseStochRSICroosingStrategy=false -> Auf Basis der 5050-Strategie wurde die Stochastik-Kreuzungsstrategie entwickelt.
	TimeSettings="Trading time";	
		StartHour=8 -> Startzeit, ab welcher der Handelsroboter die Arbeit aufnimmt
		EndHour=22 -> Ende der Arbeitszeit für den Handelsroboter
	OnlyBuyOrSellMarket="-------------------";
		OnlyBuy=true -> Es herrscht ein Kaufmarkt und man möchte nur Buy-Signale nutzen.
		OnlySell=true -> Es herrscht ein Verkäufermarkt und man möchte nur Sell-Signale nutzen.
	UserPositions="Handle user opened positions as a EA own";
		HandleUserPositions=false -> Diese Funktion übernimmt manuell eröffnete Positionen und behandelt diese nach den vorgegebenen Einstellungen mit dem dynamischen Stop Loss und Money Management, welches vorhersagt, welche Positionsgröße zunächst verwendet werden soll. Es wird  Stop Loss dynamisch nach nachgezogen, sobald die Position in Plus-Bereich kommt. Es werden eventuelle Kommissionen und Swaps berücksichtigt. Pro Symbol sollte es nur in einem Chart-Fenster installiert werden.
		CountCharsInCommentToEscape=0 -> Wenn der Broker in das Kommentarfeld eigene Informationen setzt, so können diese mit der angegebener Anzahl der Zeichen ignoriert werden.
	Common="Create signals only on new candle or on every tick";
		HandleOnCandleOpenOnly=true -> Wenn true, so wird nur bei der neuen Kerze ein Signal generiert, anderweitig werden Positionen bis zum vollständigen Ablauf der Kerze generiert.
	UsingEAOnDifferentTimeframes="-------------------";
		MagicNumber=3537 -> MagicNumber ist ein Werkzeug, welches es dem Handelsroboter ermöglicht auf den unterschiedlichen Timeframes eines Handlesinstruments zu arbeiten.

Bitte seien Sie vorsichtig bei der Wahl des Risikowertes und testen Sie diese Werte für Ihren Broker!!! Die Ergebnisse können wegen dem Spread oder anderen Spezifikationen Ihres Brokers abweichen!
Hinweise:

Je größer das Timeframe, desto sicherer, dass die Position größeren und sicheren Gewinn bring. Die kleineren Timeframes (M5-M15) sollten eher im Seitwärtsmarkt verwendet werden.
Je kleiner der Spread, desto größer der Gewinn.
Eine Verwendung von einem virtuellen Server ist empfehlenswert.



Deutsch:
Handelt den Markt bei der Trendwende bis zu einem dynamisch nachziehenden Stop Loss. Dieser Handelsroboter implementiert 2 unterschiedliche Indikatoren, welche sich auf unterschiedliche Weise kombinieren lassen. Dabei ist das Money Management so egriert, dass es einen fixen sowie einen variablen Lot erlaubt.

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

Englisch:
This EA trades based on the changes of the trend in the market, using custom indicators. There are 2 indicators: an RSI-based and a trend-based indicator. By default, the trend indicator is activated. Simultaneous use of both indicators is also possible.

In addition to fix-lot-functionality, a dynamic size calculation of a lot was implemented. It will be calculated by means of free margin and by account leverage.

We added a new function for taking over of manually opened positions.

The settings are optimized for trading on EURUSD, USDCHF, NZDUSD, GBPJPY, AUDCAD, USDJPY and GBPUSD.

Timeframes are: M15 to H4

Please be prudent in choose of risk value and test this values for your broker!!! The results can be different, because of spread or other specification of your broker!
Hs:

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
StopLoss=0 -> Standard value is 10000 pos
HandleUserPositions=false -> handle manually opened positions
StartHour=8 -> Start time for trading
EndHour=22 -> End time for trading
Optimal settings for your account can be requested via PN.

Russisch:
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






Deutsch:
Handelt den Markt bei der Trendwende bis zu einem dynamisch nachziehenden Stop Loss. Dieser Handelsroboter implementiert 2 unterschiedliche Indikatoren, welche sich auf unterschiedliche Weise kombinieren lassen. Dabei ist das Money Management so egriert, dass es einen fixen sowie einen variablen Lot erlaubt.

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
*LotAutoSize=false -> Dynamische Berechnung der Positionsgröße erlauben
*RiskPercent=25 -> Risiko für die Positionsgröße. Wird anhand des freien Margins und des Hebels berechnet
*MoneyRiskInPercent=0 -> Zur Sicherheit kann hier der empfohlene Wert von 32 eingetragen werden
UseTrendBasedIndicator=true -> den Trendindikator für Signale verwenden.
UseRSIBasedIndicator=true -> den RSI-basierten Indikator für Signale verwenden.
UseSMAOnTrendIndicator=true -> Gleitenden Mittelwert für die Signalbildung auf den Trendindikator verwenden
UseOneOrTwoSMAOnTrendIndicator=2 -> Einen oder zwei gleitenden Mittelwerte verwenden
*TrailingStep=15 -> Trailing Stop-Wert
*DistanceStep=15 -> SL-Wert
MagicNumber=3537 -> Setzen Sie pro Handelsfenster eines Währungspaares diesen Wert neu
TakeProfit=750 -> Take Profit für eventuelle Gaps
StopLoss=0 -> Standardwert ist 10000 Punkte
*StartHour=8 -> Ab diesem Zeitpunkt startet der Handel
*EndHour=22 -> Ab diesem Zeitpunkt werden keine neue Positionen an diesem Tag mehr eröffnet
*HandleUserPositions=false -> Übernehmen der manuell eröffneten Positionen
*In der kostenpflichtiger Version verfügbar! -> HIER

Optimale Einstellungen für Ihr Konto können über PN angefragt werden.

Englisch:
This EA trades based on the changes in the market, using custom indicators. The program uses two indicators: an RSI-based and a trend-based indicator. The trend-based indicator is activated by default. Simultaneous use of both indicators is also possible.

In addition to the fixed lot feature, a dynamic lot size calculation is also implemented. It will be calculated on the basis of the free margin and account leverage.

The paid version of the EA also features management of manually opened positions.

The settings are optimized for trading EURUSD, NZDUSD, GBPJPY, USDJPY, AUDCAD, USDCHF and GBPUSD on the timeframes from M15 to H4.

Please, be reasonable when choosing the risk percentage and test these values with your broker. Results may differ due to spread or other specification of your broker!


Parameters
LotSize = 0.01 -> position volume
* LotAutoSize = false-> enable dynamic calculation of the position volume
* LotRiskPercent = 25 -> risk for the position volume. It is calculated based on the free margins and the leverage
* MoneyRiskInPercent = 0 -> loss percentage, at which the program closes all opened trades
UseRSIBasedIndicator=false -> use the RSI-based indicator
UseTrendIndicator=true -> use the trend-based indicator
UseSMAOnTrendIndicator=true -> use moving average to generate a signal
UseOneOrTwoSMAOnTrendIndicator=2 -> use one or two of the moving averages
* TrailingStep = 50 -> TrailingStop value (use smaller values on the lower timeframes)
* DistanceStep = 50 -> initial SL value (use smaller values on the lower timeframes)
MagicNumber = 3537 -> magic number, set unique numbers on each chart
TakeProfit=750 -> Take profit for possible gaps
StopLoss=0 -> the standard value is 10,000 pos
*HandleUserPositions=false -> manage manually opened positions
*StartHour=8 -> time to start opening positions
*EndHour=22 -> time to stop opening positions
*Available in the full version -> here

The optimal settings for your account can be requested via private messages.

Russisch:
Робот торгует на изменении тренда на рынке, используя собственные индикаторы. В программе используются два индикатора: первый на основе RSI и индикатор на основе тренда. По умолчанию активирован индикатор тренда. Одновременное использование двух показателей также возможно.

В дополнение к фиксированному размеру позиции, в программе можно использовать динамический размер позиции. Размер рассчитывается на основе имеющейся свободной маржи и размере плеча счета.

Так же добавлена фунция перенятия вручную открытых позиций в платной версии.

Работает на EURUSD, NZDUSD, GBPJPY, USDJPY, AUDCAD, USDCHF и GBPUSD на таймфреймах от M15 до H4.

Пожалуйста, будьте благоразумны при выборе процента риска и проверьте эти значения для своего брокера!!! Результаты могут быть разными из-за спреда или другой спецификации вашего брокера!


Параметры
LotSize = 0.01 -> Размер позиции
* LotAutoSize = false-> Разрешить динамический выбор размера позиции
* LotRiskPercent = 25 -> Риск для размера позиции. Рассчитывается на основе свободной маржи и плеча
* MoneyRiskInPercent = 0 -> Значение убытка в процентах, при котором программа закрывает все открытые сделки
UseRSIBasedIndicator=false -> Использование индикатора на основе RSI
UseTrendIndicator=true -> Использование индикатора на основе тренда
UseSMAOnTrendIndicator=true -> Использование скользящих средних для создания сигнала
UseOneOrTwoSMAOnTrendIndicator=2 -> Использование одной или двух из скользящих средних
* TrailingStep = 50 -> Значение TrailingStop (используйте небольшие значения на низких таймфреймах)
* DistanceStep = 50 -> Начальное значение SL (используйте небольшие значения на низких таймфреймах)
MagicNumber = 3537 -> Магическое число, установите это значение для каждого торгового окна
TakeProfit=750 -> Take profit для возможных гэпов
StopLoss=0 -> Стандартное значение 10000 пунктов
*HandleUserPositions=false -> Перенятие вручную открытых позиций
*StartHour=8 -> Стартовое время для открытия позиций
*EndHour=22 -> Конечное время для открытия позиций
*Доступно в полной версии -> здесь

Оптимальные настройки для вашей учетной записи могут быть запрошены через PM.



